# Install Flux

## 0. Prerequisites

- RBAC permissions to create namespaces, secrets, and apply CRDs in the cluster
- GitHub Deploy Key with read access to the repository (for private repos)
- Flux CLI installed locally

## 0. Setup RBAC and GitHub Deploy Key

```bash
get_aks_subscription_id() {
  az aks show \
    --resource-group chrisfickess-tfstate-azk \
    --name mattermost-dev-chris-aks \
    --query id -o tsv
}

 az role assignment create \
  --assignee christopher.fickess@mattermost.com \
  --role "Azure Kubernetes Service RBAC Cluster Admin" \
  --scope $(get_aks_subscription_id)

azure.sandbox.connect
```


## 1. Install Flux CLI


<details>
<summary><strong>How to Install Flux in the EKS Cluster</strong></summary><br>

```bash
# Deploys all flux CRD and Flux Pods into cluster
flux install
```

</details>


#### 2. Deploy Secrets for GitRepository

<details>
<summary><strong>1. Setup Variable to Deploy Flux to EKS Cluster</strong></summary><br>

```bash
export BASEREPO="mattermost-byoc-infra"
export BYOC_REPO="planets-and-plans"

export __base_ssh_key__="$HOME/.ssh/azure/${BASEREPO}/${BASEREPO}"
export __byoc_ssh_key__="$HOME/.ssh/azure/${BYOC_REPO}/${BYOC_REPO}"

export __base_github_repo_url__="ssh://git@ssh.github.com:443/mattermost/mattermost-byoc-infra.git" # for forcing to use 443
export __byoc_github_repo_url__="ssh://git@ssh.github.com:443/christopherfickess/planets-and-plans.git" # for forcing to use 443
```

</details>


<details>
<summary><strong>2. Create Flux Git Repo Secret for Connecting to GitHub Deploy Key</strong></summary><br>

```bash
# Needed for the GitRepo kubernetes object to connect the cluster to the repo

flux create secret git $BASEREPO \
  --url=${__base_github_repo_url__} \
  --private-key-file=${__base_ssh_key__} \
  --namespace=flux-system

flux create secret git $BYOC_REPO \
  --url=${__byoc_github_repo_url__} \
  --private-key-file=${__byoc_ssh_key__} \
  --namespace=flux-system
```
</details>


#### Deploy GitRepository and Kustomization for Flux

<details>
<summary><strong>1. GitRepository File should look like the following</strong></summary>
<br>

```yaml
# clusters/<cluster-name>/flux-system/gitrepository.yaml
---
apiVersion: source.toolkit.fluxcd.io/v1
kind: GitRepository
metadata:
  name: mattermost-byoc-infra
  namespace: flux-system
spec:
  interval: 1m0s
  ref:
    branch: feature/base-addons-deployment
  secretRef:
    name: mattermost-byoc-infra
  url: ssh://git@ssh.github.com:443/mattermost/mattermost-byoc-infra.git
  ignore: |
    modules/*
    examples/*
    addons/clusters/*
---
apiVersion: source.toolkit.fluxcd.io/v1
kind: GitRepository
metadata:
  name: byoc-<customer>-<environment>
  namespace: flux-system
spec:
  interval: 1m0s
  ref:
    branch: main
  secretRef:
    name: byoc-<customer>-<environment>
  url: ssh://git@ssh.github.com:443/christopherfickess/planets-and-plans.git
  ignore: |
    modules/*
    stack/*
  include:
    - repository:
        name: mattermost-byoc-infra
      fromPath: addons/apps
      toPath: addons/base-apps
```

- Commit this file to the Repo 
- Apply the file with the following command:

```bash
BYOC_REPO="byoc-<customer>-<environment>"
kubectl apply -f clusters/$BYOC_REPO$/flux-system/gitrepository.yaml
```

</details><br>

> Note: ssh disabled on Bastion Hosts instance need to make ~/.ssh/config file to point to 443 github

#### Create Kustomization-Customer File


<details>
<summary><strong>2. Kustomization-customer File should look like the following</strong></summary><br>

```yaml
# clusters/<cluster-name>/flux-system/kustomization-overrides.yaml
# addons/clusters/byoc-staging-internal/flux-system/kustomization-customer.yaml

apiVersion: kustomize.toolkit.fluxcd.io/v1
kind: Kustomization
metadata:
  name: planets-and-plans-addons
  namespace: flux-system
spec:
  interval: 10m0s
  path: ./addons/clusters/byoc-<customer>-<environment>
  prune: true
  sourceRef:
    kind: GitRepository
    name: byoc-<customer>-<environment>
---
# stack Kustomization in cluster
apiVersion: kustomize.toolkit.fluxcd.io/v1beta2
kind: Kustomization
metadata:
  name: external-secrets
  namespace: flux-system
spec:
  interval: 10m
  path: ./addons/apps/external-secrets
  prune: true
  healthChecks:
    - apiVersion: apps/v1
      kind: Deployment
      name: external-secrets
      namespace: external-secrets
    - apiVersion: apps/v1
      kind: Deployment
      name: external-secrets-webhook
      namespace: external-secrets
  sourceRef:
    kind: GitRepository
    name: byoc-<customer>-<environment>
---
```

- Commit this file to the Repo 
- Apply the file with the following command:

```bash
BYOC_REPO="byoc-staging-internal"
kubectl apply -f clusters/$BYOC_REPO$/flux-system/kustomization-overrides.yaml
```

</details>