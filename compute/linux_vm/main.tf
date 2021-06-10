locals {
  name = format("%s%sz%s%02d%s%1s%02d",
                lookup(local.env_types, var.environment,"x"),
                lookup(local.region_map, var.rg_location, "x"),
                substr(var.app, 0, 4),
                var.server_group, substr(var.server_type, 0, 3),
                var.zone, var.server_number)

  env_types = {
    "sandbox" = "s"
    "dev"     = "d"
    "test"    = "t"
    "prod"    = "p"
  }

  region_map = {
    "centralus" = "c"
  }
  ip_portion = join(".", reverse(regex("[[:digit:]]*.[[:digit:]]*.([[:digit:]]*).([[:digit:]]*)",
                    azurerm_linux_virtual_machine.instance.private_ip_address)))
}

resource azurerm_public_ip address {
  name                = "${local.name}-public-ip"
  resource_group_name = var.rg_name
  location            = var.rg_location
  allocation_method   = "Static"
  ip_version          = "IPv4"
  zones               = [var.zone]
  sku                 = "Standard"

  tags = {
    environment = var.environment
  }
}

resource azurerm_network_interface nic {
  name                      = "${local.name}-nic"
  location                  = var.rg_location
  resource_group_name       = var.rg_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.address.id
  }
}

resource azurerm_linux_virtual_machine instance {
  name                = local.name
  resource_group_name = var.rg_name
  location            = var.rg_location
  size                = var.instance_size
  admin_username      = "ubuntu"
  network_interface_ids = [
    azurerm_network_interface.nic.id
  ]

  admin_ssh_key {
    username   = "ubuntu"
    public_key = var.ssh_public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  tags = {
    ServerGroup = "${var.app}-server-${var.server_group}"
    Name        = "${var.app}-${var.server_number}"
    App         = var.app
    NodeExport  = "true"
  }

  source_image_id = var.ami_id
  //  source_image_reference {
  //    publisher = "canonical"
  //    offer     = "0001-com-ubuntu-server-focal"
  //    sku       = "20_04-lts-gen2"
  //    version   = "latest"
  //  }
  zone            = var.zone

  dynamic "identity" {
    for_each = [for i in var.identity: {
      t = i.id_type
      s = i.id
    }]
    content {
      type         = identity.value.t
      identity_ids = [identity.value.s]
    }
  }
}

resource azurerm_private_dns_a_record prom {
  resource_group_name = var.dns_rg_name
  zone_name           = "podspace.cloud"
  ttl                 = 3600
  name                = local.name
  records             = [azurerm_linux_virtual_machine.instance.private_ip_address]
}

resource azurerm_private_dns_ptr_record reverse {
  resource_group_name = var.dns_rg_name
  zone_name           = "48.10.in-addr.arpa"
  ttl                 = 3600
  name                = local.ip_portion
  records             = [local.name]
}

resource azurerm_managed_disk storage {
  count = length(var.volume_size)
  name                 = "${local.name}-md-${count.index}"
  location             = var.rg_location
  resource_group_name  = var.rg_name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = var.volume_size[count.index]
  zones                = [var.zone]

  tags = {
    environment = var.environment
  }
}

resource azurerm_virtual_machine_data_disk_attachment attach {
  count = length(var.volume_size)
  managed_disk_id    = azurerm_managed_disk.storage.*.id[count.index]
  virtual_machine_id = azurerm_linux_virtual_machine.instance.id
  lun                = count.index + 1
  caching            = "ReadWrite"
}
