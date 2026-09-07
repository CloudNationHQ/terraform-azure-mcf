output "maintenance" {
  description = "Contains all maintenance configuration"
  value       = azurerm_maintenance_configuration.this
}

output "vm_assignments" {
  description = "Contains all virtual machine assignments"
  value       = azurerm_maintenance_assignment_virtual_machine.this
}

output "dynamic_scope_assignments" {
  description = "Contains all dynamic scope assignments"
  value       = azurerm_maintenance_assignment_dynamic_scope.this
}
