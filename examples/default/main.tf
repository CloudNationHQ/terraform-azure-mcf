module "naming" {
  source  = "cloudnationhq/naming/azure"
  version = "~> 0.24"

  suffix = ["demo", "prd"]
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
    name                     = module.naming.maintenance_configuration.name
    scope                    = "OSImage"
    resource_group_name      = module.rg.groups.demo.name
    location                 = module.rg.groups.demo.location
    in_guest_user_patch_mode = "User"
  }
}
