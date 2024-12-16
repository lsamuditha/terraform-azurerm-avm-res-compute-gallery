# This ensures we have unique CAF compliant names for our resources.
module "naming" {
  source  = "Azure/naming/azurerm"
  version = "0.4.1"
}

module "regions" {
  source                    = "Azure/avm-utl-regions/azurerm"
  version                   = "~> 0.1"
  availability_zones_filter = true
}

# This allows us to randomize the region for the resource group.
resource "random_integer" "region_index" {
  max = length(module.regions.regions) - 1
  min = 0
}

# This is required for resource modules
resource "azurerm_resource_group" "this" {
  location = module.regions.regions[random_integer.region_index.result].name
  name     = module.naming.resource_group.name_unique
  tags     = local.tags
}

module "compute_gallery" {
  source = "../../"

  location            = azurerm_resource_group.this.location
  name                = module.naming.shared_image_gallery.name_unique
  resource_group_name = azurerm_resource_group.this.name

  ## Optional
  description = "This is a test compute gallery"
  shared_image_definitions = {
    img01 = {
      name    = "lin-image"
      os_type = "Linux"
      identifier = {
        publisher = "RedHat"
        offer     = "RHEL"
        sku       = "810-gen2"
      }
    }
    img02 = {
      name    = "win-image"
      os_type = "Windows"
      identifier = {
        publisher = "MicrosoftWindowsServer"
        offer     = "WindowsServer"
        sku       = "2019-datacenter-gensecond"
      }
    }
  }
}
