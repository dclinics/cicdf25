output "vm_public_ips" {
  description = "Public IPs of the Virtual Machines"
  value = {
    for idx, name in var.vm_names : name => azurerm_public_ip.public_ip[idx].ip_address
  }
}
