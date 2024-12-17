<!-- BEGIN_TF_DOCS -->
# terraform-azurerm-avm-template

This is a template repo for Terraform Azure Verified Modules.

Things to do:

1. Set up a GitHub repo environment called `test`.
1. Configure environment protection rule to ensure that approval is required before deploying to this environment.
1. Create a user-assigned managed identity in your test subscription.
1. Create a role assignment for the managed identity on your test subscription, use the minimum required role.
1. Configure federated identity credentials on the user assigned managed identity. Use the GitHub environment.
1. Search and update TODOs within the code and remove the TODO comments once complete.

> [!IMPORTANT]
> As the overall AVM framework is not GA (generally available) yet - the CI framework and test automation is not fully functional and implemented across all supported languages yet - breaking changes are expected, and additional customer feedback is yet to be gathered and incorporated. Hence, modules **MUST NOT** be published at version `1.0.0` or higher at this time.
>
> All module **MUST** be published as a pre-release version (e.g., `0.1.0`, `0.1.1`, `0.2.0`, etc.) until the AVM framework becomes GA.
>
> However, it is important to note that this **DOES NOT** mean that the modules cannot be consumed and utilized. They **CAN** be leveraged in all types of environments (dev, test, prod etc.). Consumers can treat them just like any other IaC module and raise issues or feature requests against them as they learn from the usage of the module. Consumers should also read the release notes for each version, if considering updating to a more recent version of a module to see if there are any considerations or breaking changes etc.

<!-- markdownlint-disable MD033 -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (>= 1.7)

- <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) (>= 3.108)

- <a name="requirement_modtm"></a> [modtm](#requirement\_modtm) (~> 0.3)

- <a name="requirement_random"></a> [random](#requirement\_random) (>= 3.5.0)

## Resources

The following resources are used by this module:

- [azurerm_management_lock.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/management_lock) (resource)
- [azurerm_role_assignment.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) (resource)
- [azurerm_shared_image.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/shared_image) (resource)
- [azurerm_shared_image_gallery.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/shared_image_gallery) (resource)
- [modtm_telemetry.telemetry](https://registry.terraform.io/providers/azure/modtm/latest/docs/resources/telemetry) (resource)
- [random_uuid.telemetry](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/uuid) (resource)
- [azurerm_client_config.telemetry](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) (data source)
- [modtm_module_source.telemetry](https://registry.terraform.io/providers/azure/modtm/latest/docs/data-sources/module_source) (data source)

<!-- markdownlint-disable MD013 -->
## Required Inputs

The following input variables are required:

### <a name="input_location"></a> [location](#input\_location)

Description: (Required) Azure region where the resource should be deployed.

Type: `string`

### <a name="input_name"></a> [name](#input\_name)

Description: (Required) Specifies the name of the Shared Image Gallery. Changing this forces a new resource to be created.

Type: `string`

### <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name)

Description: The resource group where the resources will be deployed.

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_description"></a> [description](#input\_description)

Description: (Optional) The description of the shared image gallery

Type: `string`

Default: `null`

### <a name="input_enable_telemetry"></a> [enable\_telemetry](#input\_enable\_telemetry)

Description: This variable controls whether or not telemetry is enabled for the module.  
For more information see <https://aka.ms/avm/telemetryinfo>.  
If it is set to false, then no telemetry will be collected.

Type: `bool`

Default: `true`

### <a name="input_lock"></a> [lock](#input\_lock)

Description: Controls the Resource Lock configuration for this resource. The following properties can be specified:

- `kind` - (Required) The type of lock. Possible values are `\"CanNotDelete\"` and `\"ReadOnly\"`.
- `name` - (Optional) The name of the lock. If not specified, a name will be generated based on the `kind` value. Changing this forces the creation of a new resource.

Type:

```hcl
object({
    kind = string
    name = optional(string, null)
  })
```

Default: `null`

### <a name="input_role_assignments"></a> [role\_assignments](#input\_role\_assignments)

Description: A map of role assignments to create on the Key Vault. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

- `role_definition_id_or_name` - (Required) The ID or name of the role definition to assign to the principal.
- `principal_id` - (Required) The ID of the principal to assign the role to.
- `description` - (Optional) The description of the role assignment.
- `skip_service_principal_aad_check` -(Optional) If set to true, skips the Azure Active Directory check for the service principal in the tenant. Defaults to false.
- `condition` - (Optional) The condition which will be used to scope the role assignment.
- `condition_version` - (Optional) The version of the condition syntax. If you are using a condition, valid values are '2.0'.
- `delegated_managed_identity_resource_id` - (Optional) The delegated Azure Resource Id which contains a Managed Identity. Changing this forces a new resource to be created.
- `principal_type` - (Optional) The type of the principal\_id. Possible values are User, Group and ServicePrincipal. Changing this forces a new resource to be created. It is necessary to explicitly set this attribute when creating role assignments if the principal creating the assignment is constrained by ABAC rules that filters on the PrincipalType attribute.

> Note: only set `skip_service_principal_aad_check` to true if you are assigning a role to a service principal.

Type:

```hcl
map(object({
    role_definition_id_or_name             = string
    principal_id                           = string
    description                            = optional(string, null)
    skip_service_principal_aad_check       = optional(bool, false)
    condition                              = optional(string, null)
    condition_version                      = optional(string, null)
    delegated_managed_identity_resource_id = optional(string, null)
    principal_type                         = optional(string, null)
  }))
```

Default: `{}`

### <a name="input_shared_image_definitions"></a> [shared\_image\_definitions](#input\_shared\_image\_definitions)

Description: A map to create on the Key shared image definitions
- `name` - (Required) Specifies the name of the Shared Image. Changing this forces a new resource to be created.
- `identifier` - (Required) An identifier object as defined below.
  - `publisher` - (Required) The Publisher Name for this Gallery Image. Changing this forces a new resource to be created.
  - `offer` - (Required) The Offer Name for this Shared Image. Changing this forces a new resource to be created.
  - `sku` - (Required) The Name of the SKU for this Gallery Image. Changing this forces a new resource to be created.- `os_type`  - (Required) The type of Operating System present in this Shared Image. Possible values are Linux and Windows. Changing this forces a new resource to be created.      
- `os_type`  - (Required) The type of Operating System present in this Shared Image. Possible values are Linux and Windows. Changing this forces a new resource to be created.      
- `purchase_plan` - (Optional) A purchase\_plan object as defined below.
  - `name` - (Required) The Purchase Plan Name for this Shared Image. Changing this forces a new resource to be created.
  - `publisher` - (Optional) The Purchase Plan Publisher for this Gallery Image. Changing this forces a new resource to be created.
  - `product` - (Optional) The Purchase Plan Product for this Gallery Image. Changing this forces a new resource to be created.
- `description` - (Optional) A description of this Shared Image.
- `disk_types_not_allowed` - (Optional) One or more Disk Types not allowed for the Image. Possible values include Standard\_LRS and Premium\_LRS.
- `end_of_life_date` - (Optional) The end of life date in RFC3339 format of the Image.
- `eula` - (Optional) The End User Licence Agreement for the Shared Image. Changing this forces a new resource to be created.
- `specialized` - (Optional) Specifies that the Operating System used inside this Image has not been Generalized (for example, sysprep on Windows has not been run). Changing this forces a new resource to be created.
> Note: It's recommended to Generalize images where possible - Specialized Images reuse the same UUID internally within each Virtual Machine, which can have unintended side-effects.
- `architecture` - (Optional) CPU architecture supported by an OS. Possible values are x64 and Arm64. Defaults to x64. Changing this forces a new resource to be created.
- `hyper_v_generation` - (Optional) The generation of HyperV that the Virtual Machine used to create the Shared Image is based on. Possible values are V1 and V2. Defaults to V1. Changing this forces a new resource to be created.
- `max_recommended_vcpu_count` - (Optional) Maximum count of vCPUs recommended for the Image.
- `min_recommended_vcpu_count` - (Optional) Minimum count of vCPUs recommended for the Image.
- `max_recommended_memory_in_gb` - (Optional) Maximum memory in GB recommended for the Image.
- `min_recommended_memory_in_gb` - (Optional) Minimum memory in GB recommended for the Image.
- `privacy_statement_uri` - (Optional) The URI containing the Privacy Statement associated with this Shared Image. Changing this forces a new resource to be created.
- `release_note_uri` - (Optional) The URI containing the Release Notes associated with this Shared Image.
- `trusted_launch_supported` - (Optional) Specifies if supports creation of both Trusted Launch virtual machines and Gen2 virtual machines with standard security created from the Shared Image. Changing this forces a new resource to be created.
- `trusted_launch_enabled` - (Optional) Specifies if Trusted Launch has to be enabled for the Virtual Machine created from the Shared Image. Changing this forces a new resource to be created.
- `confidential_vm_supported` - (Optional) Specifies if supports creation of both Confidential virtual machines and Gen2 virtual machines with standard security from a compatible Gen2 OS disk VHD or Gen2 Managed image. Changing this forces a new resource to be created.
- `confidential_vm_enabled` - (Optional) Specifies if Confidential Virtual Machines enabled. It will enable all the features of trusted, with higher confidentiality features for isolate machines or encrypted data. Available for Gen2 machines. Changing this forces a new resource to be created.
- `accelerated_network_support_enabled` - (Optional) Specifies if the Shared Image supports Accelerated Network. Changing this forces a new resource to be created.
- `tags` - (Optional) A mapping of tags to assign to the Shared Image.
> Note: Only one of `trusted_launch_supported`, `trusted_launch_enabled`, `confidential_vm_supported` and `confidential_vm_enabled` can be specified.

Type:

```hcl
map(object({
    name = string
    identifier = object({
      publisher = string
      offer     = string
      sku       = string
    })
    os_type = string
    purchase_plan = optional(object({
      name      = string
      publisher = optional(string)
      product   = optional(string)
    }))
    description                         = optional(string)
    disk_types_not_allowed              = optional(list(string))
    end_of_life_date                    = optional(string)
    eula                                = optional(string)
    specialized                         = optional(bool)
    architecture                        = optional(string, "x64")
    hyper_v_generation                  = optional(string, "V1")
    max_recommended_vcpu_count          = optional(number)
    min_recommended_vcpu_count          = optional(number)
    max_recommended_memory_in_gb        = optional(number)
    min_recommended_memory_in_gb        = optional(number)
    privacy_statement_uri               = optional(string)
    release_note_uri                    = optional(string)
    trusted_launch_enabled              = optional(bool)
    confidential_vm_supported           = optional(bool)
    confidential_vm_enabled             = optional(bool)
    accelerated_network_support_enabled = optional(bool)
    tags                                = optional(map(string))
  }))
```

Default: `{}`

### <a name="input_sharing"></a> [sharing](#input\_sharing)

Description: A sharing object that supports the following:
- `permission` - (Required) The permission of the Shared Image Gallery when sharing. Possible values are Community, Groups and Private. Changing this forces a new resource to be created.
> Note: This requires that the Preview Feature Microsoft.Compute/CommunityGalleries is enabled, see the documentation for more information.
- `community_gallery` - (Optional) A community\_gallery object that supports the following:
  - `eula` - (Required) The End User Licence Agreement for the Shared Image Gallery. Changing this forces a new resource to be created.
  - `prefix` - (Required) Prefix of the community public name for the Shared Image Gallery. Changing this forces a new resource to be created.
  - `publisher_email` - (Required) Email of the publisher for the Shared Image Gallery. Changing this forces a new resource to be created.     
  - `publisher_uri` - (Required) URI of the publisher for the Shared Image Gallery. Changing this forces a new resource to be created.
> Note: `community_gallery` must be set when `permission` is set to `Community`.

Type:

```hcl
object({
    permission = string
    community_gallery = optional(object({
      eula            = string
      prefix          = string
      publisher_email = string
      publisher_uri   = string
    }))
  })
```

Default: `null`

### <a name="input_tags"></a> [tags](#input\_tags)

Description: (Optional) Tags of the resource.

Type: `map(string)`

Default: `null`

### <a name="input_timeouts"></a> [timeouts](#input\_timeouts)

Description:  - `create` - (Defaults to 60 minutes) Used when creating the Shared Image Gallery.
 - `delete` - (Defaults to 60 minutes) Used when deleting the Shared Image Gallery.
 - `read` - (Defaults to 5 minutes) Used when retrieving the Shared Image Gallery.
 - `update` - (Defaults to 60 minutes) Used when updating the Shared Image Gallery.

Type:

```hcl
object({
    create = optional(string)
    delete = optional(string)
    read   = optional(string)
    update = optional(string)
  })
```

Default: `null`

## Outputs

The following outputs are exported:

### <a name="output_name"></a> [name](#output\_name)

Description: The name of the Image Gallery.

### <a name="output_resource_id"></a> [resource\_id](#output\_resource\_id)

Description: The id of the Image Gallery.

## Modules

No modules.

<!-- markdownlint-disable-next-line MD041 -->
## Data Collection

The software may collect information about you and your use of the software and send it to Microsoft. Microsoft may use this information to provide services and improve our products and services. You may turn off the telemetry as described in the repository. There are also some features in the software that may enable you and Microsoft to collect data from users of your applications. If you use these features, you must comply with applicable law, including providing appropriate notices to users of your applications together with a copy of Microsoft’s privacy statement. Our privacy statement is located at <https://go.microsoft.com/fwlink/?LinkID=824704>. You can learn more about data collection and use in the help documentation and our privacy statement. Your use of the software operates as your consent to these practices.
<!-- END_TF_DOCS -->