resource "azurerm_maintenance_configuration" "this" {
  resource_group_name = coalesce(
    var.maintenance.resource_group_name, var.resource_group_name
  )

  location = coalesce(
    var.maintenance.location, var.location
  )

  name                     = var.maintenance.name
  scope                    = var.maintenance.scope
  in_guest_user_patch_mode = var.maintenance.in_guest_user_patch_mode

  visibility = var.maintenance.visibility
  properties = var.maintenance.properties

  tags = coalesce(
    var.maintenance.tags, var.tags
  )

  dynamic "window" {
    for_each = var.maintenance.window != null ? { "this" = var.maintenance.window } : {}

    content {
      start_date_time      = window.value.start_date_time
      expiration_date_time = window.value.expiration_date_time
      duration             = window.value.duration
      time_zone            = window.value.time_zone
      recur_every          = window.value.recur_every
    }
  }

  dynamic "install_patches" {
    for_each = var.maintenance.install_patches != null ? { "this" = var.maintenance.install_patches } : {}

    content {
      reboot = install_patches.value.reboot

      dynamic "linux" {
        for_each = install_patches.value.linux != null ? { "this" = install_patches.value.linux } : {}

        content {
          classifications_to_include    = linux.value.classifications_to_include
          package_names_mask_to_exclude = linux.value.package_names_mask_to_exclude
          package_names_mask_to_include = linux.value.package_names_mask_to_include
        }
      }

      dynamic "windows" {
        for_each = install_patches.value.windows != null ? { "this" = install_patches.value.windows } : {}

        content {
          classifications_to_include = windows.value.classifications_to_include
          kb_numbers_to_exclude      = windows.value.kb_numbers_to_exclude
          kb_numbers_to_include      = windows.value.kb_numbers_to_include
        }
      }
    }
  }
}

resource "azurerm_maintenance_assignment_virtual_machine" "this" {
  for_each = var.maintenance.vm_assignments

  location = coalesce(
    var.maintenance.location, var.location
  )

  maintenance_configuration_id = azurerm_maintenance_configuration.this.id
  virtual_machine_id           = each.value.virtual_machine_id
}

resource "azurerm_maintenance_assignment_dynamic_scope" "this" {
  for_each = var.maintenance.dynamic_scope_assignments

  name                         = each.value.name
  maintenance_configuration_id = azurerm_maintenance_configuration.this.id

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
