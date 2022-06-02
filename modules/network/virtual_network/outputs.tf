output net_name {
  value = azurerm_virtual_network.net.name
}

output net_id {
  value = azurerm_virtual_network.net.id
}

output subnet_1_id {
  value = azurerm_subnet.subnet_1.id
}

output subnet_1_name {
  value = azurerm_subnet.subnet_1.name
}

output subnet_2_id {
  value = azurerm_subnet.subnet_2.id
}

output subnet_2_name {
  value = azurerm_subnet.subnet_2.name
}
