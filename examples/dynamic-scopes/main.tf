module "naming" {
  source  = "cloudnationhq/naming/azure"
  version = "~> 0.24"

  suffix = ["demo", "dev"]
}

module "rg" {
  source  = "cloudnationhq/rg/azure"
  version = "~> 2.0"

  groups = {
    demo = {
      name     = module.naming.resource_group.name_unique
      location = "westeurope"
    }
  }
}

module "maintenance" {
  source  = "cloudnationhq/mcf/azure"
  version = "~> 1.0"

  config = {
    name                      = module.naming.maintenance_configuration.name
    scope                     = "InGuestPatch"
    in_guest_user_patch_mode  = "User"
    resource_group_name       = module.rg.groups.demo.name
    location                  = module.rg.groups.demo.location
    dynamic_scope_assignments = local.dynamic_scope_assignments

    window = {
      start_date_time      = "2026-01-03 00:00"
      expiration_date_time = "2026-12-31 00:00"
      duration             = "03:00"
      time_zone            = "UTC"
      recur_every          = "Week"
    }

    install_patches = {
      linux = {
        classifications_to_include    = ["Critical", "Security"]
        package_names_mask_to_exclude = ["dontpatch*"]
        package_names_mask_to_include = ["important*"]
      }

      windows = {
        classifications_to_include = ["Critical", "Security"]
        kb_numbers_to_exclude      = ["KB123453"]
        kb_numbers_to_include      = ["KB654321"]
      }
    }
  }
}
