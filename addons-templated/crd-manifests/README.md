# crds/

Raw CRD (CustomResourceDefinition) YAML files that must exist in the cluster
before any Helm chart that uses them can deploy successfully.

## Why a separate folder?

Helm has limitations with CRDs:
- Helm only installs CRDs on first `helm install` — it skips them on `helm upgrade`
- If a CRD install fails mid-deploy, it's hard to recover cleanly
- Some charts (e.g. prometheus-operator) bundle hundreds of CRDs that slow down releases

Flux solves this by letting you apply CRDs through a dedicated **Kustomization** resource
with `prune: false`. This means:
- CRDs are applied before any app that depends on them (`dependsOn` in the apps HelmRelease)
- Flux will **never auto-delete** a CRD even if you remove it from this folder — you must
  delete it manually (`kubectl delete crd <name>`), which protects you from accidentally
  dropping all objects of that type across the cluster

## How it fits with dev / staging / prod

CRDs are **environment-agnostic** — the same CRD versions run on all clusters.
Env-specific configuration (replicas, storage size, node selectors, etc.) lives in
`cluster-overrides/<env>/values.yaml`, not here.

The chain Flux follows per cluster:

```
GitRepository (this repo)
    └── Kustomization: cluster-crds       ← applies crds/ with prune: false
            └── HelmRelease: flux-addons  ← deploys addons/apps/ chart
                    dependsOn: cluster-crds
```

The `flux-kustomizations.yaml` in each `cluster-overrides/<env>/` folder defines
both of these Flux objects with the correct `dependsOn` wiring.

## Adding a new CRD

1. Find the CRD YAML on the upstream chart's GitHub releases page.
   Most charts publish a standalone `crds/` bundle or a `<chart>-crds.yaml` file.
2. Download it and place it in this folder.
3. Add the filename to `kustomization.yaml` under `resources:`.
4. Commit and push. Flux picks it up on the next sync interval.

> **Tip:** Pin the CRD file to the same version as the chart in `values.yaml`.
> When you upgrade the chart version, update the CRD file at the same time.
