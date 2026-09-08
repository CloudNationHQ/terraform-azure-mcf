moved {
  from = azurerm_maintenance_configuration.mcf
  to   = azurerm_maintenance_configuration.this
}

moved {
  from = azurerm_maintenance_assignment_virtual_machine.mcf_vm
  to   = azurerm_maintenance_assignment_virtual_machine.this
}

moved {
  from = azurerm_maintenance_assignment_dynamic_scope.mcf_ds
  to   = azurerm_maintenance_assignment_dynamic_scope.this
}
