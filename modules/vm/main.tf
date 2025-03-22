variable "vm_names" {
  type = list(string)
}

variable "rg_name" {
  type = string
}

variable "location" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "nsg_id" {
  type = string
}

variable "cloud_init" {
  type = string
}

variable "admin_password" {
  type    = string
  default = "Admin123@"
}

# Public IP for each VM
resource "azurerm_public_ip" "public_ip" {
  count               = length(var.vm_names)
  name                = "${var.vm_names[count.index]}-public-ip"
  location            = var.location
  resource_group_name = var.rg_name
  allocation_method   = "Static"
}

# Network Interface for each VM
resource "azurerm_network_interface" "nic" {
  count               = length(var.vm_names)
  name                = "${var.vm_names[count.index]}-nic"
  location            = var.location
  resource_group_name = var.rg_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip[count.index].id
  }
}

# Attach NSG to each NIC
resource "azurerm_network_interface_security_group_association" "nsg_association" {
  count                     = length(var.vm_names)
  network_interface_id      = azurerm_network_interface.nic[count.index].id
  network_security_group_id = var.nsg_id
}

# Create Virtual Machines
resource "azurerm_linux_virtual_machine" "vm" {
  count               = length(var.vm_names)
  name                = var.vm_names[count.index]
  resource_group_name = var.rg_name
  location            = var.location
  size                = "Standard_B2ms"
  admin_username      = "azureuser"
  admin_password      = var.admin_password
  network_interface_ids = [azurerm_network_interface.nic[count.index].id]
  disable_password_authentication = false

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy-daily"
    sku       = "22_04-daily-lts-gen2"
    version   = "latest"
  }

  custom_data = base64encode(var.cloud_init)
}

# # Output Public IPs
# output "vm_public_ips" {
#   value = azurerm_public_ip.public_ip[*].ip_address
# }
