variable "maintenance" {
  description = "Contains all maintenance configuration"
  type = object({
    name                     = string
    scope                    = string
    resource_group_name      = optional(string)
    location                 = optional(string)
    in_guest_user_patch_mode = optional(string)
    visibility               = optional(string)
    properties               = optional(map(string))
    tags                     = optional(map(string))
    window = optional(object({
      start_date_time      = string
      expiration_date_time = optional(string)
      duration             = string
      time_zone            = string
      recur_every          = string
    }))
    install_patches = optional(object({
      reboot = optional(string)
      linux = optional(object({
        classifications_to_include    = optional(list(string))
        package_names_mask_to_exclude = optional(list(string))
        package_names_mask_to_include = optional(list(string))
      }))
      windows = optional(object({
        classifications_to_include = optional(list(string))
        kb_numbers_to_exclude      = optional(list(string))
        kb_numbers_to_include      = optional(list(string))
      }))
    }))
    vm_assignments = optional(map(object({
      virtual_machine_id = string
    })), {})
    dynamic_scope_assignments = optional(map(object({
      name = string
      filter = object({
        locations       = optional(list(string))
        os_types        = optional(list(string))
        resource_groups = optional(list(string))
        resource_types  = optional(list(string))
        tag_filter      = optional(string)
        tags = optional(list(object({
          tag    = string
          values = list(string)
        })), [])
      })
    })), {})
  })

  validation {
    condition     = lookup(var.maintenance, "location", null) != null || var.location != null
    error_message = "location must be set on var.maintenance.location or on the module-level var.location."
  }

  validation {
    condition     = lookup(var.maintenance, "resource_group_name", null) != null || var.resource_group_name != null
    error_message = "resource_group_name must be set on var.maintenance.resource_group_name or on the module-level var.resource_group_name."
  }
}

variable "location" {
  description = "default azure region and can be used if location is not specified inside the object."
  type        = string
  default     = null
}

variable "resource_group_name" {
  description = "default resource group and can be used if resourcegroup is not specified inside the object."
  type        = string
  default     = null
}

variable "tags" {
  description = "tags to be added to the resources"
  type        = map(string)
  default     = {}
}
