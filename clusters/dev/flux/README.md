# Flux — Dev Cluster

This folder contains the Flux resource definitions for the dev cluster.

## Folder contents

| File | What it does |
|------|-------------|
| `gitrepositories.yaml` | GitRepository sources for both repos — requires SSH secrets to exist first |
| `cluster-crds.yaml` | Kustomization — applies CRDs from `kubernetes-base-addons` repo (`prune: false`, never auto-deleted) |
| `kubernetes-base-addons.yaml` | Kustomization — depends on `cluster-crds`, reconciles `clusters/dev/addons/` to apply the HelmRelease |

**Reconciliation order:**
```
cluster-crds → kubernetes-base-addons (HelmRelease)
```

---

## Fresh Flux Deploy

### 1. Install Flux controllers into the cluster

```bash
flux install
```

---

### 2. Generate SSH deploy keys for both repos

```bash
# kubernetes-base-addons repo (the addons chart)
ssh-keygen -t ed25519 -f ~/.ssh/kubernetes-base-addons/kubernetes-base-addons -C "flux@kubernetes-base-addons" -N ""

# terraform-aws-eks repo (this repo — cluster config)
ssh-keygen -t ed25519 -f ~/.ssh/terraform-aws-eks/terraform-aws-eks -C "flux@terraform-aws-eks" -N ""
```

---

### 3. Add the public keys as GitHub Deploy Keys

Go to each repo → **Settings → Deploy keys → Add deploy key** (read-only is sufficient):

```bash
export __base_repo_name__="kubernetes-base-addons"
export __overrides_repo_name__="terraform-aws-eks"

cat ~/.ssh/${__base_repo_name__}/${__base_repo_name__}.pub        # → add to kubernetes-base-addons repo
cat ~/.ssh/${__overrides_repo_name__}/${__overrides_repo_name__}.pub  # → add to terraform-aws-eks repo
```

---

### 4. Create the Git secrets in the cluster

```bash
flux create secret git ${__base_repo_name__} \
  --url=ssh://git@github.com/mattermost-platform/${__base_repo_name__} \
  --private-key-file=${HOME}/.ssh/${__base_repo_name__}/${__base_repo_name__} \
  --namespace=flux-system

flux create secret git ${__overrides_repo_name__} \
  --url=ssh://git@github.com/mattermost-platform/${__overrides_repo_name__} \
  --private-key-file=${HOME}/.ssh/${__overrides_repo_name__}/${__overrides_repo_name__} \
  --namespace=flux-system
```

> **Bastion note:** SSH outbound on port 22 is blocked on the bastion. Use the GitHub SSH-over-HTTPS endpoint instead:
> `ssh://git@ssh.github.com:443/mattermost/<repo>`

---

### 5. Register the pod-identity-webhook

The EKS control plane runs a webhook server at `127.0.0.1:23443` that injects AWS credentials into pods whose ServiceAccount has an `eks.amazonaws.com/role-arn` annotation. Without it, IRSA annotations are silently ignored.

> **Note:** In a Cilium+EKS cluster the webhook call itself fails silently for Helm-deployed workloads — the control plane cannot reach ClusterIP services. You still need this webhook registered so the `eks.amazonaws.com/role-arn` annotation is recognised by the STS call. Explicitly mount the projected token and set `AWS_ROLE_ARN` / `AWS_WEB_IDENTITY_TOKEN_FILE` via `extraValues` for each addon. See `docs/debugging/cilium-eks-control-plane-networking.md` in `kubernetes-base-addons` for the per-chart pattern.

```bash
CA=$(kubectl config view --raw --minify --flatten -o jsonpath='{.clusters[].cluster.certificate-authority-data}')
kubectl apply -f - <<EOF
apiVersion: admissionregistration.k8s.io/v1
kind: MutatingWebhookConfiguration
metadata:
  name: pod-identity-webhook
webhooks:
  - admissionReviewVersions:
      - v1beta1
    clientConfig:
      caBundle: "${CA}"
      url: https://127.0.0.1:23443/mutate
    failurePolicy: Ignore
    matchPolicy: Equivalent
    name: iam-for-pods.amazonaws.com
    namespaceSelector: {}
    objectSelector:
      matchExpressions:
        - key: eks.amazonaws.com/skip-pod-identity-webhook
          operator: DoesNotExist
    reinvocationPolicy: IfNeeded
    rules:
      - apiGroups:
          - ""
        apiVersions:
          - v1
        operations:
          - CREATE
        resources:
          - pods
        scope: "*"
    sideEffects: None
    timeoutSeconds: 10
EOF
```

Verify it registered:
```bash
kubectl get mutatingwebhookconfigurations | grep pod-identity
```

---

### 6. Apply the bootstrap

```bash
kubectl apply -k terraform-modules/terraform-aws-eks/examples/basic/clusters/dev/
```

This applies the Flux resource definitions and generates the `flux-addons-values-dev` ConfigMap from `addons/values.yaml`. After this single apply, Flux owns everything — day-to-day changes go through Git.

> **Why `clusters/dev/` and not `clusters/dev/flux/`?**
>
> `flux/` holds the Flux *resource definitions* — what Flux manages once it is running.
> `clusters/dev/` is the *bootstrap entry point* — the one-time manual apply that hands control to Flux.
> `clusters/dev/kustomization.yaml` does two things `flux/` cannot:
> 1. Generates the `flux-addons-values-dev` ConfigMap from `addons/values.yaml` (the HelmRelease needs this on first boot)
> 2. Applies `gitrepositories.yaml` so Flux has Git sources before it tries to reconcile anything
>
> After this one apply, you never touch `kubectl apply` again — Flux reconciles everything from Git.

---

### 7. Watch it come up

```bash
# Watch all Kustomizations
flux get kustomizations --watch

# Watch all HelmReleases
flux get hr -A --watch

# Check for errors across all namespaces
flux logs --level=error --all-namespaces
```

---

### Force reconcile (if something is stuck)

```bash
# Pull latest commits from Git
flux reconcile source git -n flux-system kubernetes-base-addons
flux reconcile source git -n flux-system terraform-aws-eks

# Re-apply CRDs and the HelmRelease
flux reconcile kustomization -n flux-system cluster-crds
flux reconcile kustomization -n flux-system kubernetes-base-addons

# Force a full Helm upgrade (use --force sparingly — it deletes and recreates resources)
flux reconcile helmrelease -n flux-system kubernetes-base-addons --with-source
```

---

### Useful debug commands

```bash
# Check GitRepository sync status
kubectl get gitrepositories -A

# Describe a failing Kustomization
kubectl describe kustomization <name> -n flux-system

# Describe a failing HelmRelease
kubectl describe helmrelease kubernetes-base-addons -n flux-system

# Tail helm-controller logs
kubectl logs -n flux-system -l app=helm-controller --tail=50

# Tail kustomize-controller logs
kubectl logs -n flux-system -l app=kustomize-controller --tail=50
```
