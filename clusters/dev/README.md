# Dev Cluster — `clusters/dev/`

This directory contains all cluster-specific configuration for the dev EKS cluster: Flux resource definitions, addon override values, and extra Kubernetes resources.

**Before you start here:** The EKS cluster, node groups, bastion, S3 buckets, and IRSA roles must already exist.
See [../README.md](../README.md) for the full Terraform provisioning steps.

---

## Directory structure

```
clusters/dev/
├── kustomization.yaml              # Bootstrap entry point — one-time kubectl apply
├── values.yaml                     # Addon override values for this cluster
│
├── flux-system/                    # Flux resource definitions (managed by Flux after bootstrap)
│   ├── README.md                   # ← FULL BOOTSTRAP WALKTHROUGH — start here for Flux deploy
│   ├── gitrepositories.yaml        # GitRepository sources for both repos (needs SSH secrets first)
│   ├── bootstrap-kustomization.yaml # Self-referential Kustomization — hands control to Flux
│   ├── cluster-crds.yaml           # CRD Kustomization (prune: false — never auto-deleted)
│   ├── kubernetes-base-addons.yaml # HelmRelease Kustomization (depends on cluster-crds)
│   ├── helmrelease.yaml            # HelmRelease for the flux-addons umbrella chart
│   └── kustomization.yaml          # Scoped to helmrelease.yaml only (see note in that file)
│
├── addons/                         # Example resources for specific addons
│   ├── external-secrets-examples/  # ExternalSecret test — validates ESO → Secrets Manager
│   ├── grafana-examples/           # ServiceAccount (IRSA) and SOPS-encrypted admin secret
│   └── velero-examples/            # BackupStorageLocation and SOPS-encrypted credentials
│
└── extras/                         # Raw Kubernetes resources applied by Flux after CRDs exist
    └── postgres-test/              # In-cluster Postgres for ESO → Mattermost connection testing
```

---

## Where to go for what

| Task | Go to |
|------|-------|
| First-time Flux deploy (SSH keys, secrets, bootstrap apply) | [flux-system/README.md](flux-system/README.md) |
| Provision the cluster infrastructure first (EKS, S3, IRSA) | [../README.md](../README.md) |
| Understand the addon chart structure and available flags | [kubernetes-base-addons README](https://github.com/mattermost-platform/kubernetes-base-addons/blob/main/README.md) |
| Per-addon flag reference (grafana, loki, velero, etc.) | [kubernetes-base-addons docs/templates/](https://github.com/mattermost-platform/kubernetes-base-addons/tree/main/docs/templates) |
| How Flux resources relate to each other in the addon chart | [flux-resource-map.md](https://github.com/mattermost-platform/kubernetes-base-addons/blob/main/docs/flux-resource-map.md) |
| Set up Flux Slack / webhook alerts | [flux-notifications.md](https://github.com/mattermost-platform/kubernetes-base-addons/blob/main/docs/flux-notifications.md) |
| Encrypt secrets with SOPS before committing | [sops-integration.md](https://github.com/mattermost-platform/kubernetes-base-addons/blob/main/docs/sops-integration.md) |
| Debug a stuck Flux reconciliation | [flux-system/README.md — Force reconcile](flux-system/README.md#force-reconcile-if-something-is-stuck) |

---

## How bootstrap works

`kustomization.yaml` is the **one-time manual apply** that hands control to Flux. It does three things `flux-system/` alone cannot:

1. Generates the `flux-addons-values-dev` ConfigMap from `values.yaml` — the HelmRelease reads values from this ConfigMap
2. Applies `flux-system/gitrepositories.yaml` — Flux needs Git sources before it can fetch anything
3. Applies `flux-system/bootstrap-kustomization.yaml` — the self-referential Kustomization that gives Flux permanent ownership of this path

After that single `kubectl apply -k clusters/dev/`, Flux reconciles everything from Git. No manual `kubectl apply` needed for day-to-day changes.

**Reconciliation order after bootstrap:**
```
cluster-crds (CRDs applied) → kubernetes-base-addons (HelmRelease deployed)
```

---

## Bootstrap (short version)

Full walkthrough with commands: **[flux-system/README.md](flux-system/README.md)**

```bash
BASE_ADDONS_REPO="kubernetes-base-addons"
OVERRIDE_REPO="terraform-aws-eks"

# 1. Install Flux controllers into the cluster
flux install

# 2. Generate SSH deploy keys and add public keys to GitHub (see flux-system/README.md §2–3)
ssh-keygen -t ed25519 -f ~/.ssh/${BASE_ADDONS_REPO}/${BASE_ADDONS_REPO} -C "flux@${BASE_ADDONS_REPO}" -N ""
ssh-keygen -t ed25519 -f ~/.ssh/${OVERRIDE_REPO}/${OVERRIDE_REPO}         -C "flux@${OVERRIDE_REPO}"   -N ""

# GitHub → Repo → Settings → Deploy keys → Add key (read-only is sufficient)

# 3. Create the Git secrets in the cluster
flux create secret git "${BASE_ADDONS_REPO}" \
  --url=ssh://git@github.com/mattermost-platform/${BASE_ADDONS_REPO} \
  --private-key-file=${HOME}/.ssh/${BASE_ADDONS_REPO}/${BASE_ADDONS_REPO} \
  --namespace=flux-system

flux create secret git "${OVERRIDE_REPO}" \
  --url=ssh://git@github.com/mattermost-platform/${OVERRIDE_REPO} \
  --private-key-file=${HOME}/.ssh/${OVERRIDE_REPO}/${OVERRIDE_REPO} \
  --namespace=flux-system

# 4. Apply the bootstrap (one-time only — from examples/basic/)
kubectl apply -k clusters/dev/

# 5. Watch it come up
flux get kustomizations --watch
flux get hr -A --watch
```

---

## Changing addon configuration

Edit `values.yaml` and push. Flux picks up the change within the `helmRepoInterval` (1 minute in dev).

```bash
# Check reconciliation status after pushing
flux get hr -A
flux logs --level=error --all-namespaces
```

For available flags per addon, see the [docs/templates/](https://github.com/mattermost-platform/kubernetes-base-addons/tree/main/docs/templates) reference docs.
To add an entirely new chart without a dedicated template, use the `wrapperCharts` mechanism — see the [kubernetes-base-addons README](https://github.com/mattermost-platform/kubernetes-base-addons/blob/main/README.md#wrapperchart--deploying-arbitrary-helm-charts).

---

## Adding extra Kubernetes resources

Extra raw resources (ExternalSecrets, StatefulSets, RBAC) go under `extras/` and are listed in `kustomization.yaml`.
These are applied by Flux after the HelmRelease is ready — CRDs must exist before resources that depend on them (e.g. `ExternalSecret`) can be applied.

```yaml
# kustomization.yaml — add new extras here once Flux and CRDs are running
resources:
  - extras/my-new-resource/manifest.yaml
```

---

## Addon-specific example resources

The `addons/` subdirectories contain example files for addon configurations that fall outside the umbrella chart.
They are commented out in `kustomization.yaml` by default — uncomment what you need and push.

| Directory | What it contains | When to use it |
|-----------|-----------------|----------------|
| `addons/external-secrets-examples/` | Test `ExternalSecret` — pulls `dev-app-mattermost` from Secrets Manager | Validates ESO + IRSA wiring after first deploy |
| `addons/grafana-examples/` | Example IRSA `ServiceAccount` and SOPS-encrypted admin `Secret` | Override Grafana SA annotation or pre-create the admin password secret |
| `addons/velero-examples/` | Example `BackupStorageLocation` and SOPS-encrypted AWS credentials | Add a second backup location or use static credentials instead of IRSA |

For SOPS encryption of any secret file, see [sops-integration.md](https://github.com/mattermost-platform/kubernetes-base-addons/blob/main/docs/sops-integration.md).
