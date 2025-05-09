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

module "network" {
  source  = "cloudnationhq/vnet/azure"
  version = "~> 8.0"

  naming = local.naming

  vnet = {
    name           = module.naming.virtual_network.name
    location       = module.rg.groups.demo.location
    resource_group = module.rg.groups.demo.name
    address_space  = ["10.18.0.0/16"]

    subnets = {
      int = {
        address_prefixes       = ["10.18.1.0/24"]
        network_security_group = {}
      }
    }
  }
}

module "kv" {
  source  = "cloudnationhq/kv/azure"
  version = "~> 4.0"

  naming = local.naming

  vault = {
    name                = module.naming.key_vault.name_unique
    location            = module.rg.groups.demo.location
    resource_group_name = module.rg.groups.demo.name
  }
}

module "vm1" {
  source  = "cloudnationhq/vm/azure"
  version = "~> 6.0"

  keyvault   = module.kv.vault.id
  naming     = local.naming
  depends_on = [module.kv]

  instance = {
    type                = "linux"
    name                = "${module.naming.linux_virtual_machine.name}1"
    resource_group_name = module.rg.groups.demo.name
    location            = module.rg.groups.demo.location
    patch_mode          = "AutomaticByPlatform"

    bypass_platform_safety_checks_on_user_schedule_enabled = true

    generate_ssh_key = {
      enable = true
    }
    source_image_reference = {
      offer     = "UbuntuServer"
      publisher = "Canonical"
      sku       = "18.04-LTS"
    }

    interfaces = {
      int1 = {
        ip_configurations = {
          config1 = {
            subnet_id = module.network.subnets.int.id
            primary   = true
          }
        }
      }
    }
  }
}

module "vm2" {
  source  = "cloudnationhq/vm/azure"
  version = "~> 6.0"

  keyvault   = module.kv.vault.id
  naming     = local.naming
  depends_on = [module.kv]

  instance = {
    type                = "linux"
    name                = "${module.naming.linux_virtual_machine.name}2"
    resource_group_name = module.rg.groups.demo.name
    location            = module.rg.groups.demo.location
    patch_mode          = "AutomaticByPlatform"

    bypass_platform_safety_checks_on_user_schedule_enabled = true

    generate_ssh_key = {
      enable = true
    }
    source_image_reference = {
      offer     = "UbuntuServer"
      publisher = "Canonical"
      sku       = "18.04-LTS"
    }

    interfaces = {
      int2 = {
        ip_configurations = {
          config1 = {
            subnet_id = module.network.subnets.int.id
            primary   = true
          }
        }
      }
    }
    disks = {
      data = {
        disk_size_gb = 10
        lun          = 0
      }
    }
  }
}

module "maintenance" {
  source  = "cloudnationhq/mcf/azure"
  version = "~> 1.0"

  config = {
    name                     = module.naming.maintenance_configuration.name
    resource_group_name      = module.rg.groups.demo.name
    location                 = module.rg.groups.demo.location
    in_guest_user_patch_mode = "User"
    scope                    = "InGuestPatch"

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

    vm_assignments = {
      vm1 = {
        virtual_machine_id = module.vm1.instance.id
      }
      vm2 = {
        virtual_machine_id = module.vm2.instance.id
      }
    }
  }
}
