locals {
  ip_parts = regex("([[:digit:]]*).([[:digit:]]*).[[:digit:]]*.[[:digit:]]*.*", var.cidr_block)
}

resource azurerm_virtual_network net {
  name                = "${var.subarea}-central-us"
  location            = var.rg_location
  resource_group_name = var.rg_name
  address_space       = [var.cidr_block]

  tags = {
    environment = var.environment
  }
}

resource azurerm_subnet subnet_1 {
  name                 = "${var.subarea}-subnet-1"
  resource_group_name  = azurerm_virtual_network.net.resource_group_name
  virtual_network_name = azurerm_virtual_network.net.name
  address_prefixes     = [cidrsubnet(var.cidr_block, var.subnet_bits, var.base_net + 1)]
}

resource azurerm_subnet subnet_2 {
  name                 = "${var.subarea}-subnet-2"
  resource_group_name  = azurerm_virtual_network.net.resource_group_name
  virtual_network_name = azurerm_virtual_network.net.name
  address_prefixes     = [cidrsubnet(var.cidr_block, var.subnet_bits, var.base_net + 2)]
}

resource azurerm_network_security_group network_sg {
  name                = "${var.environment}_net_sg"
  location            = var.rg_location
  resource_group_name = var.rg_name

#  security_rule {
#    name                       = "tcp-in-ssh"
#    priority                   = 100
#    direction                  = "Inbound"
#    access                     = "Allow"
#    protocol                   = "Tcp"
#    source_port_range          = "*"
#    destination_port_range     = "22"
#    source_address_prefix      = "*"
#    destination_address_prefix = "*"
#  }
#  security_rule {
#    name                       = "tcp-in-http"
#    priority                   = 110
#    direction                  = "Inbound"
#    access                     = "Allow"
#    protocol                   = "Tcp"
#    source_port_range          = "*"
#    destination_port_range     = "80"
#    source_address_prefix      = "*"
#    destination_address_prefix = "*"
#  }
#  security_rule {
#    name                       = "tcp-in-https"
#    priority                   = 120
#    direction                  = "Inbound"
#    access                     = "Allow"
#    protocol                   = "Tcp"
#    source_port_range          = "*"
#    destination_port_range     = "443"
#    source_address_prefix      = "*"
#    destination_address_prefix = "*"
#  }
#  security_rule {
#    name                       = "tcp-in-kube-nodeports"
#    priority                   = 130
#    direction                  = "Inbound"
#    access                     = "Allow"
#    protocol                   = "Tcp"
#    source_port_range          = "*"
#    destination_port_range     = "30000-32500"
#    source_address_prefix      = "*"
#    destination_address_prefix = "*"
#  }
#  security_rule {
#    name                       = "tcp-in-kube-alt-port-1"
#    priority                   = 140
#    direction                  = "Inbound"
#    access                     = "Allow"
#    protocol                   = "Tcp"
#    source_port_range          = "*"
#    destination_port_range     = "4443"
#    source_address_prefix      = "*"
#    destination_address_prefix = "*"
#  }
#  security_rule {
#    name                       = "tcp-in-kube-metrics-port"
#    priority                   = 150
#    direction                  = "Inbound"
#    access                     = "Allow"
#    protocol                   = "Tcp"
#    source_port_range          = "*"
#    destination_port_range     = "10250"
#    source_address_prefix      = "*"
#    destination_address_prefix = "*"
#  }

  security_rule {
    name                       = "vnet-allow"
    priority                   = 200
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
  }

  security_rule {
    name                       = "internet-deny"
    priority                   = 210
    direction                  = "Outbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "Internet"
  }

  tags = {
    environment = var.environment
  }
}

resource azurerm_subnet_network_security_group_association filter {
  network_security_group_id = azurerm_network_security_group.network_sg.id
  subnet_id                 = azurerm_subnet.subnet_1.id
}

resource azurerm_private_dns_zone local {
  name                = var.domain_name
  resource_group_name = var.rg_name
}

resource azurerm_private_dns_zone reverse {
  name                = "${local.ip_parts[1]}.${local.ip_parts[0]}.in-addr.arpa"
  resource_group_name = var.rg_name
}

resource azurerm_private_dns_zone_virtual_network_link name_link {
  name                  = "name-link"
  resource_group_name   = var.rg_name
  virtual_network_id    = azurerm_virtual_network.net.id
  private_dns_zone_name = azurerm_private_dns_zone.local.name
}

resource azurerm_private_dns_zone_virtual_network_link reverse_link {
  name                  = "reverse-link"
  resource_group_name   = var.rg_name
  virtual_network_id    = azurerm_virtual_network.net.id
  private_dns_zone_name = azurerm_private_dns_zone.reverse.name
}

resource azurerm_route_table private_route_table {
  location            = var.rg_location
  resource_group_name = var.rg_name
  name                = "private-route-table"
}

resource azurerm_route local {
  name                = "private-route"
  resource_group_name = var.rg_name
  route_table_name    = azurerm_route_table.private_route_table.name
  address_prefix      = var.cidr_block
  next_hop_type       = "VNetLocal"
}

resource azurerm_subnet_route_table_association private_net {
  subnet_id      = azurerm_subnet.subnet_1.id
  route_table_id = azurerm_route_table.private_route_table.id
}
