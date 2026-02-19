# -----------------------------------------------------------------------------
# Optional: Public DNS zone + CNAME for Mattermost (dev-chris -> LB FQDN)
# -----------------------------------------------------------------------------
# When create_public_mattermost_cname = true, creates Azure public DNS zone
# and CNAME record. Zone must be delegated from parent (e.g. cloud.mattermost.com).
# CNAME record is manual if you use Cloudflare or another provider.
# -----------------------------------------------------------------------------

resource "azurerm_dns_zone" "mattermost_public" {
  count = var.create_public_mattermost_cname ? 1 : 0

  name                = var.public_mattermost_zone_name
  resource_group_name = var.resource_group_name
}

resource "azurerm_dns_cname_record" "mattermost" {
  count = var.create_public_mattermost_cname ? 1 : 0

  name                = var.public_mattermost_cname_name
  zone_name           = azurerm_dns_zone.mattermost_public[0].name
  resource_group_name = var.resource_group_name
  ttl                 = 300
  record              = var.public_mattermost_cname_target
}
