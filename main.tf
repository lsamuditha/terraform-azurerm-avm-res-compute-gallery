resource "azurerm_shared_image_gallery" "this" {
  location            = var.location
  name                = var.name
  resource_group_name = var.resource_group_name
  description         = var.description
  tags                = var.tags

  dynamic "sharing" {
    for_each = var.sharing != null ? [var.sharing] : []

    content {
      permission = sharing.value.permission

      dynamic "community_gallery" {
        for_each = sharing.value.community_gallery != null ? [sharing.value.community_gallery] : []

        content {
          eula            = community_gallery.value.eula
          prefix          = community_gallery.value.prefix
          publisher_email = community_gallery.value.publisher_email
          publisher_uri   = community_gallery.value.publisher_uri
        }
      }
    }
  }
  dynamic "timeouts" {
    for_each = var.timeouts != null ? [var.timeouts] : []

    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
      read   = timeouts.value.read
      update = timeouts.value.update
    }
  }
}

resource "azurerm_shared_image" "this" {
  for_each = var.shared_image_definitions

  gallery_name = azurerm_shared_image_gallery.this.name
  location     = var.location
  ## Required Inputs
  name                                = each.value.name
  os_type                             = each.value.os_type
  resource_group_name                 = var.resource_group_name
  accelerated_network_support_enabled = each.value.accelerated_network_support_enabled
  architecture                        = each.value.architecture
  confidential_vm_enabled             = each.value.confidential_vm_enabled
  confidential_vm_supported           = each.value.confidential_vm_supported
  description                         = each.value.description
  disk_types_not_allowed              = each.value.disk_types_not_allowed
  end_of_life_date                    = each.value.end_of_life_date
  eula                                = each.value.eula
  hyper_v_generation                  = each.value.hyper_v_generation
  max_recommended_memory_in_gb        = each.value.max_recommended_memory_in_gb
  max_recommended_vcpu_count          = each.value.max_recommended_vcpu_count
  min_recommended_memory_in_gb        = each.value.min_recommended_memory_in_gb
  min_recommended_vcpu_count          = each.value.min_recommended_vcpu_count
  privacy_statement_uri               = each.value.privacy_statement_uri
  release_note_uri                    = each.value.release_note_uri
  specialized                         = each.value.specialized
  tags                                = each.value.tags
  trusted_launch_enabled              = each.value.trusted_launch_enabled

  identifier {
    offer     = each.value.identifier.offer
    publisher = each.value.identifier.publisher
    sku       = each.value.identifier.sku
  }
  ## Optional Inputs
  dynamic "purchase_plan" {
    for_each = each.value.purchase_plan != null ? [each.value.purchase_plan] : []

    content {
      name      = purchase_plan.value.name
      product   = purchase_plan.value.product
      publisher = purchase_plan.value.publisher
    }
  }
}

# required AVM resources interfaces
resource "azurerm_management_lock" "this" {
  count = var.lock != null ? 1 : 0

  lock_level = var.lock.kind
  name       = coalesce(var.lock.name, "lock-${var.lock.kind}")
  scope      = azurerm_shared_image_gallery.this.id
  notes      = var.lock.kind == "CanNotDelete" ? "Cannot delete the resource or its child resources." : "Cannot delete or modify the resource or its child resources."
}

resource "azurerm_role_assignment" "this" {
  for_each = var.role_assignments

  principal_id                           = each.value.principal_id
  scope                                  = azurerm_shared_image_gallery.this.id
  condition                              = each.value.condition
  condition_version                      = each.value.condition_version
  delegated_managed_identity_resource_id = each.value.delegated_managed_identity_resource_id
  role_definition_id                     = strcontains(lower(each.value.role_definition_id_or_name), lower(local.role_definition_resource_substring)) ? each.value.role_definition_id_or_name : null
  role_definition_name                   = strcontains(lower(each.value.role_definition_id_or_name), lower(local.role_definition_resource_substring)) ? null : each.value.role_definition_id_or_name
  skip_service_principal_aad_check       = each.value.skip_service_principal_aad_check
}
