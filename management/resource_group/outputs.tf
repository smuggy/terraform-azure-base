output rg_name {
  description = "resource group name"
  value       = azurerm_resource_group.resource_group.name
}

output rg_id {
  description = "resource group id"
  value       = azurerm_resource_group.resource_group.id
}

output rg_location {
  description = "resource group location"
  value       = azurerm_resource_group.resource_group.location
}
