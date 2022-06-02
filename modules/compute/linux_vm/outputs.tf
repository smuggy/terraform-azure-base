output name {
  value = azurerm_linux_virtual_machine.instance.name
}

output public_ip {
  value = azurerm_linux_virtual_machine.instance.public_ip_address
}

output private_ip {
  value = azurerm_linux_virtual_machine.instance.private_ip_address
}

output nic_id {
  value = azurerm_network_interface.nic.id
}
