locals {
  dynamic_scope_assignments = {
    windows_vms = {
      name = "windows"
      filter = {
        locations       = ["West Europe"]
        os_types        = ["Windows"]
        resource_groups = [module.rg.groups.demo.name]
        resource_types  = ["Microsoft.Compute/virtualMachines"]
      }
    },
    linux_vms = {
      name = "linux"
      filter = {
        locations       = ["West Europe"]
        os_types        = ["Linux"]
        resource_groups = [module.rg.groups.demo.name]
        resource_types  = ["Microsoft.Compute/virtualMachines"]
      }
    }
  }
}
