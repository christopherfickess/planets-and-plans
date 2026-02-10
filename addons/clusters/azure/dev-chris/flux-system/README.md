
1. You must first create a the Deploy Key

<br>
<details>
<summary><strong>Create SSH Key Commands:</strong></summary><br>

> ```bash 
> # Create key and bootstrap flux to github repo
> CLUSTER_NAME="<cluster-name>"
> 
> mkdir -p ~/.ssh/${CLUSTER_NAME}
> cd ~/.ssh/${CLUSTER_NAME}/
> 
> export __github_passphrase__="" # Blank for flux
> 
> ssh-keygen -t ed25519 -f flux-${CLUSTER_NAME}-key -C "flux@${CLUSTER_NAME}" -N "${__github_passphrase__}"
> ```


> ```bash 
> # Create key and bootstrap flux to github repo
> CLUSTER_NAME="<cluster-name>-base-repo"
> 
> mkdir -p ~/.ssh/${CLUSTER_NAME}
> cd ~/.ssh/${CLUSTER_NAME}/
> 
> export __github_passphrase__="" # Blank for flux
> 
> ssh-keygen -t ed25519 -f flux-${CLUSTER_NAME}-key -C "flux@${CLUSTER_NAME}" -N "${__github_passphrase__}"
> ```

</details>
<br>


2. Add **public** keys to repo:
GitHub → Repo → Settings → Deploy keys → Add key
  
    a. Name: `flux-${CLUSTER_NAME}-key`

    b. Key: contents of `flux-${CLUSTER_NAME}-deploy-key.pub`
      - ✅ Allow write access (if Flux needs to commit)


```bash
export base_repo="base-config"
export cluster_override="cluster-config"
export CLUSTER_NAME="dev-chris"
export __base_ssh_key__="$HOME/.ssh/${CLUSTER_NAME}-base-repo/flux-${CLUSTER_NAME}-base-repo-key"
export __overrides_ssh_key__="$HOME/.ssh/${CLUSTER_NAME}/flux-${CLUSTER_NAME}-key"
export __overrides_github_repo_url__="ssh://git@ssh.github.com:443/christopherfickess/planets-and-plans.git" # for forcing to use 443
export __base_github_repo_url__="ssh://git@ssh.github.com:443/mattermost/mattermost-byoc-infra.git" # for forcing to use 443
```
2. Create Flux Base Git Repo Secret for Connecting to GitHub Deploy Key

```bash
# Needed for the GitRepo kubernetes object to connect the cluster to the repo
flux create secret git ${base_repo} \
  --url=${__base_github_repo_url__} \
  --private-key-file=${__base_ssh_key__} \
  --namespace=flux-system

  
flux create secret git ${cluster_override} \
  --url=${__overrides_github_repo_url__} \
  --private-key-file=${__overrides_ssh_key__} \
  --namespace=flux-system
```


```bash
flux bootstrap git \
  --branch="${__branch_name__}" \
  --password="${__github_passphrase__}" \
  --path=${__kustomize_dir__} \
  --private-key-file="${__ssh_key__}" \
  --url=${__github_repo_url__} 
```