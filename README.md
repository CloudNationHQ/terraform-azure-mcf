# Maintenance Configuration

This terraform module simplifies the configuration and management of maintenance schedules. It offers extensive customization options to match your specific maintenance needs, streamlining the provisioning and update management process.

## Features

Utilization of Terratest for robust validation

Supports multiple virtual machine assignments

Flexible dynamic scope targeting based on resource criteria

<!-- BEGIN_TF_DOCS -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (~> 1.0)

- <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) (~> 4.0)

## Providers

The following providers are used by this module:

- <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) (~> 4.0)

## Resources

The following resources are used by this module:

- [azurerm_maintenance_assignment_dynamic_scope.mcf_ds](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/maintenance_assignment_dynamic_scope) (resource)
- [azurerm_maintenance_assignment_virtual_machine.mcf_vm](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/maintenance_assignment_virtual_machine) (resource)
- [azurerm_maintenance_configuration.mcf](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/maintenance_configuration) (resource)

## Required Inputs

The following input variables are required:

### <a name="input_config"></a> [config](#input\_config)

Description: Contains all maintenance configuration

Type:

```hcl
object({
    name                     = string
    scope                    = optional(string, "All")
    resource_group_name      = optional(string)
    location                 = optional(string)
    in_guest_user_patch_mode = optional(string)
    visibility               = optional(string, "Custom")
    properties               = optional(map(string), {})
    tags                     = optional(map(string))
    window = optional(object({
      start_date_time      = string
      expiration_date_time = optional(string)
      duration             = string
      time_zone            = optional(string, "UTC")
      recur_every          = string
    }))
    install_patches = optional(object({
      reboot = optional(string, "Always")
      linux = optional(object({
        classifications_to_include    = optional(list(string), ["Critical", "Security"])
        package_names_mask_to_exclude = optional(list(string), [])
        package_names_mask_to_include = optional(list(string), [])
      }))
      windows = optional(object({
        classifications_to_include = optional(list(string), ["Critical", "Security"])
        kb_numbers_to_exclude      = optional(list(string), [])
        kb_numbers_to_include      = optional(list(string), [])
      }))
    }))
    vm_assignments = optional(map(object({
      virtual_machine_id = string
    })), {})
    dynamic_scope_assignments = optional(map(object({
      name = string
      filter = object({
        locations       = optional(list(string), [])
        os_types        = optional(list(string), [])
        resource_groups = optional(list(string), [])
        resource_types  = optional(list(string), [])
        tag_filter      = optional(string)
        tags = optional(list(object({
          tag    = string
          values = list(string)
        })), [])
      })
    })), {})
  })
```

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_location"></a> [location](#input\_location)

Description: default azure region and can be used if location is not specified inside the object.

Type: `string`

Default: `null`

### <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name)

Description: default resource group and can be used if resourcegroup is not specified inside the object.

Type: `string`

Default: `null`

### <a name="input_tags"></a> [tags](#input\_tags)

Description: tags to be added to the resources

Type: `map(string)`

Default: `{}`

## Outputs

The following outputs are exported:

### <a name="output_config"></a> [config](#output\_config)

Description: Contains all maintenance configuration
<!-- END_TF_DOCS -->

## Goals

For more information, please see our [goals and non-goals](./GOALS.md).

## Testing

For more information, please see our testing [guidelines](./TESTING.md)

## Notes

Using a dedicated module, we've developed a naming convention for resources that's based on specific regular expressions for each type, ensuring correct abbreviations and offering flexibility with multiple prefixes and suffixes.

Full examples detailing all usages, along with integrations with dependency modules, are located in the examples directory.

To update the module's documentation run `make doc`

## Contributors

We welcome contributions from the community! Whether it's reporting a bug, suggesting a new feature, or submitting a pull request, your input is highly valued.

For more information, please see our contribution [guidelines](./CONTRIBUTING.md). <br><br>

<a href="https://github.com/cloudnationhq/terraform-azure-mcf/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=cloudnationhq/terraform-azure-mcf" />
</a>

## License

MIT Licensed. See [LICENSE](./LICENSE) for full details.

## References

- [Documentation](https://learn.microsoft.com/en-us/azure/virtual-machines/maintenance-configurations)
- [Rest Api](https://learn.microsoft.com/en-us/rest/api/maintenance/maintenance-configurations)
