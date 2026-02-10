resource "azurerm_public_ip" "nat_public_ip" {
  name                = var.nat_public_ip_name
  location            = var.location
  resource_group_name = var.resource_group_name

  allocation_method = "Static"
  sku               = "Standard"

  tags = merge({
    Name = var.nat_public_ip_name },
    var.tags
  )
}

resource "azurerm_nat_gateway" "nat_gateway" {
  name                = var.nat_gateway_name
  location            = var.location
  resource_group_name = var.resource_group_name

  sku_name = "Standard"

  tags = merge({
    Name = var.nat_gateway_name },
    var.tags
  )
}

resource "azurerm_nat_gateway_public_ip_association" "nat_gateway_association" {
  nat_gateway_id       = azurerm_nat_gateway.nat_gateway.id
  public_ip_address_id = azurerm_public_ip.nat_public_ip.id
}


resource "azurerm_subnet_nat_gateway_association" "subnet_nat" {
  depends_on = [
    azurerm_nat_gateway_public_ip_association.nat_gateway_association,
    module.avm-res-network-virtualnetwork
  ]

  for_each = data.azurerm_subnet.subnets

  subnet_id      = each.value.id
  nat_gateway_id = azurerm_nat_gateway.nat_gateway.id
}
