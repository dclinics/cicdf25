terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
  use_cli = true # Uses Azure CLI credentials
}

# Generate cloud-init from the template
locals {
  cloud_init = templatefile("${path.module}/cloud-init.tpl", {
    users  = var.users
    passwd = var.passwd
  })
}

# Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "devopclinics-cicd-rg"
  location = "eastus2"
}

# Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = "devopclinics-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Subnet
resource "azurerm_subnet" "subnet" {
  name                 = "devopclinics-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Network Security Group (NSG) for RKE2 Kubernetes Cluster
resource "azurerm_network_security_group" "nsg" {
  name                = "devopclinics-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  # Allow SSH from the Internet (Modify source IP for security)
  security_rule {
    name                       = "Allow-SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

}

# Deploy Virtual Machines
module "dc_lab_vm" {
  source     = "./modules/vm"
  vm_names   = ["cicd1", "cicd-t1", "cicd-t2"]
  rg_name    = azurerm_resource_group.rg.name
  subnet_id  = azurerm_subnet.subnet.id
  nsg_id     = azurerm_network_security_group.nsg.id
  location   = azurerm_resource_group.rg.location
  cloud_init = local.cloud_init
  admin_password = "Admin123@"
}
