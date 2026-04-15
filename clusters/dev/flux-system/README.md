# Flux System — Dev Cluster

This folder contains all Flux resource definitions for the dev cluster.

## Folder contents

| File | What it does |
|------|-------------|
| `gitrepositories.yaml` | GitRepository sources for both repos — requires SSH secrets to exist first |
| `bootstrap-kustomization.yaml` | Kustomization — self-referential; tells Flux to watch `clusters/dev/` and reconcile from Git permanently |
| `cluster-crds.yaml` | Kustomization — applies `./crds` from `kubernetes-base-addons` repo (prune: false, never auto-deleted) |
| `kubernetes-base-addons.yaml` | Kustomization — depends on `cluster-crds`, reconciles this folder to apply the HelmRelease |
| `helmrelease.yaml` | HelmRelease — deploys the `flux-addons` Helm chart with dev values |
| `kustomization.yaml` | Lists only `helmrelease.yaml` — used by the `kubernetes-base-addons` Kustomization when it reconciles this path |

**Reconciliation order:**
```
cluster-crds → kubernetes-base-addons (HelmRelease)
```

To add a new Flux-managed resource set: add a new Kustomization YAML here, reference it in `clusters/dev/kustomization.yaml`, and add your manifests under `clusters/dev/extras/<app>/`.

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

cat ~/.ssh/${__base_repo_name__}/${__base_repo_name__}.pub   # → add to kubernetes-base-addons repo
cat ~/.ssh/${__overrides_repo_name__}/${__overrides_repo_name__}.pub        # → add to terraform-aws-eks repo
```

---

### 4. Create the Git secrets in the cluster

```bash
 flux create secret git ${__base_repo_name__}   \
    --url=ssh://git@github.com/mattermost-platform/${__base_repo_name__} \
    --private-key-file=${HOME}/.ssh/${__base_repo_name__}/${__base_repo_name__} \
    --namespace=flux-system

 flux create secret git ${__overrides_repo_name__}  \
    --url=ssh://git@github.com/mattermost-platform/${__overrides_repo_name__}   \
    --private-key-file=${HOME}/.ssh/${__overrides_repo_name__}/${__overrides_repo_name__} \
    --namespace=flux-system
```

> **Bastion note:** SSH outbound on port 22 is blocked on the bastion. Use the GitHub SSH-over-HTTPS endpoint instead:
> `ssh://git@ssh.github.com:443/mattermost/<repo>`

---

### 5. Apply the bootstrap

```bash
kubectl apply -k terraform-modules/terraform-aws-eks/examples/basic/clusters/dev/
```

This only applies Flux resource definitions — `extras/` is commented out in `kustomization.yaml` by design. The bootstrap runs before CRDs exist in the cluster, so `ExternalSecret` resources would fail. Flux installs everything in order after this point.

### 6. Enable extras (after Flux is running)

Once `flux get hr -A` shows `kubernetes-base-addons` as `Ready`, external-secrets is installed and its CRDs exist. Then:

1. Uncomment `- extras/` in `clusters/dev/kustomization.yaml`
2. Commit and push
3. Flux reconciles it automatically — no `kubectl apply` needed

> **Why `clusters/dev/` and not `clusters/dev/flux-system/`?**
>
> `flux-system/` holds the Flux *resource definitions* — what Flux manages once it is running.
> `clusters/dev/` is the *bootstrap entry point* — the one-time manual apply that hands control to Flux.
> `clusters/dev/kustomization.yaml` does three things `flux-system/` cannot:
> 1. Generates the `flux-addons-values-dev` ConfigMap from `values.yaml` (the HelmRelease needs this)
> 2. Applies `gitrepositories.yaml` (without these, Flux has no Git sources)
> 3. Applies `bootstrap-kustomization.yaml` (the self-referential Kustomization that gives Flux permanent control)
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
flux reconcile kustomization cluster-crds -n flux-system
flux reconcile kustomization kubernetes-base-addons -n flux-system
flux reconcile hr kubernetes-base-addons -n flux-system
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
