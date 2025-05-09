# maintenance config
resource "azurerm_maintenance_configuration" "mcf" {

  resource_group_name = coalesce(
    lookup(
      var.config, "resource_group_name", null
    ), var.resource_group_name
  )

  location = coalesce(
    lookup(var.config, "location", null
    ), var.location
  )

  name                     = var.config.name
  scope                    = var.config.scope
  in_guest_user_patch_mode = var.config.in_guest_user_patch_mode

  visibility = var.config.visibility
  properties = var.config.properties

  tags = coalesce(
    var.config.tags, var.tags
  )

  dynamic "window" {
    for_each = var.config.window != null ? [var.config.window] : []

    content {
      start_date_time      = window.value.start_date_time
      expiration_date_time = window.value.expiration_date_time
      duration             = window.value.duration
      time_zone            = window.value.time_zone
      recur_every          = window.value.recur_every
    }
  }

  dynamic "install_patches" {
    for_each = var.config.install_patches != null ? [var.config.install_patches] : []

    content {
      reboot = var.config.install_patches.reboot
      dynamic "linux" {
        for_each = try(install_patches.value.linux, null) != null ? [install_patches.value.linux] : []

        content {
          classifications_to_include    = linux.value.classifications_to_include
          package_names_mask_to_exclude = linux.value.package_names_mask_to_exclude
          package_names_mask_to_include = linux.value.package_names_mask_to_include
        }
      }

      dynamic "windows" {
        for_each = try(install_patches.value.windows, null) != null ? [install_patches.value.windows] : []

        content {
          classifications_to_include = windows.value.classifications_to_include
          kb_numbers_to_exclude      = windows.value.kb_numbers_to_exclude
          kb_numbers_to_include      = windows.value.kb_numbers_to_include
        }
      }
    }
  }
}

# vm assignments
resource "azurerm_maintenance_assignment_virtual_machine" "mcf_vm" {
  for_each = var.config.vm_assignments

  location = coalesce(
    lookup(var.config, "location", null
    ), var.location
  )

  maintenance_configuration_id = azurerm_maintenance_configuration.mcf.id
  virtual_machine_id           = each.value.virtual_machine_id
}

# dynamic scope assignments
resource "azurerm_maintenance_assignment_dynamic_scope" "mcf_ds" {
  for_each = var.config.dynamic_scope_assignments

  name                         = each.value.name
  maintenance_configuration_id = azurerm_maintenance_configuration.mcf.id

  filter {
    locations       = each.value.filter.locations
    os_types        = each.value.filter.os_types
    resource_groups = each.value.filter.resource_groups
    resource_types  = each.value.filter.resource_types
    tag_filter      = each.value.filter.tag_filter

    dynamic "tags" {
      for_each = each.value.filter.tags

      content {
        tag    = tags.value.tag
        values = tags.value.values
      }
    }
  }
}
