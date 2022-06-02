resource azurerm_resource_group resource_group {
  name     = "${var.group}-${var.name}-rg"
  location = var.location

  timeouts {
    create = "10m"
    delete = "30m"
  }
}
