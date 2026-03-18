
1. You must first create a the Deploy Key

<br>
<details>
<summary><strong>Create SSH Key Commands:</strong></summary><br>

> ```bash 
> # Create key and bootstrap flux to github repo
> customer_name="<customer-name>"
> 
> mkdir -p ~/.ssh/azure/${customer_name}
> cd ~/.ssh/azure/${customer_name}/
> 
> export __github_passphrase__="" # Blank for flux
> 
> ssh-keygen -t ed25519 -f flux-${customer_name}-key -C "flux@${customer_name}" -N "${__github_passphrase__}"
> ```


> ```bash 
> # Create key and bootstrap flux to github repo
> customer_name="<customer-name>-mattermost-byoc-infra"
> 
> mkdir -p ~/.ssh/azure/${customer_name}
> cd ~/.ssh/azure/${customer_name}/
> 
> export __github_passphrase__="" # Blank for flux
> 
> ssh-keygen -t ed25519 -f flux-${customer_name}-key -C "flux@${customer_name}" -N "${__github_passphrase__}"
> ```

</details>
<br>


2. Add **public** keys to repo:
GitHub → Repo → Settings → Deploy keys → Add key
  
    a. Name: `flux-${customer_name}-key`

    b. Key: contents of `flux-${customer_name}-deploy-key.pub`
      - ✅ Allow write access (if Flux needs to commit)

3. Install flux

```
flux install
```

If you get this error 

```
install failed: Namespace/flux-system dry-run failed (Forbidden): namespaces "flux-system" is forbidden: User "user-name@email.com" cannot patch resource "namespaces" in API group "" in the namespace "flux-system": User does not have access to the resource in Azure. Update role assignment to allow access.
```

**You need to add your rbac permissions to your subscription**

```bash
EMAIL_ADDRESS="<email-address>"
MY_ID=$(az ad user show --id "${EMAIL_ADDRESS}" --query id --output tsv)
customer_name="mattermost-dev-aks" # example
RESOURCE_GROUP_NAME="chrisfickess-tfstate-azk"

az role assignment create \
  --assignee "${MY_ID}" \
  --role "Azure Kubernetes Service RBAC Cluster Admin" \
  --scope "/subscriptions/${AZURE_SUBSCRIPTION_ID}/resourceGroups/${RESOURCE_GROUP_NAME}/providers/Microsoft.ContainerService/managedClusters/${customer_name}"
```

Refresh your credentials to the cluster (could take 2-5 mins)

4. Deploy the secrets to the cluster

```bash
export base_repo="mattermost-byoc-infra"
export organization_name="<github-org-name>"
export customer_name="<customer-name>"
export customer_repo_name="<customer-repo-name>"
export customer_name="dev-chris"
__branch_name__
export __base_ssh_key__="$HOME/.ssh/azure/${customer_name}-mattermost-byoc-infra/mattermost-byoc-infra"
export __overrides_ssh_key__="$HOME/.ssh/azure/${customer_name}-${customer_repo_name}/planets-and-plans"
export __overrides_github_repo_url__="ssh://git@ssh.github.com:443/${organization_name}$/${customer_repo_name}.git" # for forcing to use 443
export __base_github_repo_url__="ssh://git@ssh.github.com:443/mattermost/mattermost-byoc-infra.git" # for forcing to use 443
```
2. Create Flux Base Git Repo Secret for Connecting to GitHub Deploy Key

```bash
# Needed for the GitRepo kubernetes object to connect the cluster to the repo
flux create secret git ${base_repo} \
  --url=${__base_github_repo_url__} \
  --private-key-file=${__base_ssh_key__} \
  --namespace=flux-system

  
flux create secret git ${customer_repo_name} \
  --url=${__overrides_github_repo_url__} \
  --private-key-file=${__overrides_ssh_key__} \
  --namespace=flux-system
```

```bash
kubectl apply -f addons/clusters/azure/<customer-env>/flux-system/.
```