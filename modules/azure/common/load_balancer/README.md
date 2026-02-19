# Azure Load Balancer Module

Template module for Azure load balancers with NLB or ALB options.

## lb_type Options

| Value | Azure Resource | Use Case |
|-------|----------------|----------|
| `nlb` | Standard Load Balancer (L4) | TCP/UDP load balancing. TLS at app (e.g. Envoy Gateway). |
| `alb` | Application Gateway (L7) | HTTP/HTTPS, path-based routing, SSL termination, WAF. |

## Usage

```hcl
module "load_balancer" {
  source = "../../../modules/azure/common/load_balancer"

  lb_type             = "nlb"  # or "alb"
  unique_name_prefix  = "mattermost-dev-chris"
  resource_group_name = var.resource_group_name
  location            = var.location
  vnet_name           = var.vnet_name
  subnet_name         = var.subnet_name  # For ALB: use dedicated appgw-subnet
  tags                = local.tags
}
```

## Stable FQDN (CNAME target)

The module sets a DNS label on the Public IP, creating a stable hostname like AWS ELB:

- **Output:** `fqdn` (or `nlb_fqdn` / `alb_fqdn`)
- **Format:** `{dns_label}.{region}.cloudapp.azure.com` (e.g. `mattermost-dev-chris-nlb.eastus2.cloudapp.azure.com`)
- **Use:** Create a CNAME from your domain (e.g. `dev-chris.dev.cloud.mattermost.com`) to this FQDN. The hostname is stable; if the IP changes, Azure updates resolution automatically.

Override the label with `dns_label`; otherwise it is derived from `unique_name_prefix` + `-nlb` or `-alb`.

## Kubernetes Annotations (envoy-gateway)

Use outputs with Kubernetes LoadBalancer service annotations:

**NLB (static IP):**
```yaml
annotations:
  service.beta.kubernetes.io/azure-load-balancer-resource-group: "<resource_group_name>"
  service.beta.kubernetes.io/azure-pip-name: "<nlb_pip_name>"
```

**ALB:** Application Gateway typically integrates via AGIC (Application Gateway Ingress Controller) or custom ingress—not via standard LoadBalancer service annotations.

## ALB Subnet Requirement

Application Gateway requires a **dedicated subnet** with no other resources. Create a subnet (e.g. `appgw-subnet`) with at least `/26` (e.g. `10.0.3.0/26`).

## Template Status

This is a template for future use. Backend pools and routing rules are placeholders—expand when integrating with AKS/ingress.
