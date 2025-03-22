output "vm_ips" {
  description = "Public IPs of all Virtual Machines"
  value       = module.dc_lab_vm.vm_public_ips
}
