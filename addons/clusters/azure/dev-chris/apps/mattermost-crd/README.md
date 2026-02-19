# Mattermost CRD

Installs the `Mattermost` CRD (`installation.mattermost.com/v1beta1`) before the Mattermost app. The base-apps from mattermost-byoc-infra may not include the CRD.

**Source:** [mattermost-operator/config/crd/bases](https://github.com/mattermost/mattermost-operator/blob/master/config/crd/bases/installation.mattermost.com_mattermosts.yaml)

If Flux/Kustomize cannot fetch the remote URL (e.g. restricted network), download the CRD locally:

```bash
curl -sL "https://raw.githubusercontent.com/mattermost/mattermost-operator/master/config/crd/bases/installation.mattermost.com_mattermosts.yaml" \
  -o addons/clusters/azure/dev-chris/apps/mattermost-crd/installation.mattermost.com_mattermosts.yaml
```

Then update `kustomization.yaml` to use the local file instead of the URL:

```yaml
resources:
  - installation.mattermost.com_mattermosts.yaml
```
