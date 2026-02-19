


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


flux install


export BASEREPO="mattermost-byoc-infra"
export BYOC_REPO="planets-and-plans"

export __base_ssh_key__="$HOME/.ssh/azure/${BASEREPO}/${BASEREPO}"
export __byoc_ssh_key__="$HOME/.ssh/azure/${BYOC_REPO}/${BYOC_REPO}"

export __base_github_repo_url__="ssh://git@ssh.github.com:443/mattermost/mattermost-byoc-infra.git" # for forcing to use 443
export __byoc_github_repo_url__="ssh://git@ssh.github.com:443/christopherfickess/planets-and-plans.git" # for forcing to use 443


flux create secret git $BASEREPO \
  --url=${__base_github_repo_url__} \
  --private-key-file=${__base_ssh_key__} \
  --namespace=flux-system

flux create secret git $BYOC_REPO \
  --url=${__byoc_github_repo_url__} \
  --private-key-file=${__byoc_ssh_key__} \
  --namespace=flux-system


# Install mattermost crd 
kubectl apply -f https://raw.githubusercontent.com/mattermost/mattermost-helm/refs/heads/master/charts/mattermost-operator/crds/crd-mattermosts.yaml


BYOC_REPO="dev-chris"
kubectl apply -f clusters/azure/$BYOC_REPO/flux-system/.