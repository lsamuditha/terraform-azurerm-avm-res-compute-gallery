resource "azurerm_shared_image_gallery" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  description         = var.description
  tags                = var.tags
}
resource "azurerm_shared_image" "this" {
  for_each            = var.shared_image_definations
  name                = each.value.name
  gallery_name        = try(var.gallery_name, azurerm_shared_image_gallery.this.name)
  resource_group_name = var.resource_group_name
  location            = var.location
  os_type             = each.value.os_type
  hyper_v_generation  = each.value.hyper_v_generation
  identifier {
    publisher = each.value.identifier.publisher
    offer     = each.value.identifier.offer
    sku       = each.value.identifier.sku
  }
}


# TODO: Replace this dummy resource azurerm_resource_group.TODO with your module resource
resource "azurerm_resource_group" "TODO" {
  location = var.location
  name     = var.name # calling code must supply the name
  tags     = var.tags
}

# required AVM resources interfaces
resource "azurerm_management_lock" "this" {
  count = var.lock != null ? 1 : 0

  lock_level = var.lock.kind
  name       = coalesce(var.lock.name, "lock-${var.lock.kind}")
  scope      = azurerm_resource_group.this.id
  notes      = var.lock.kind == "CanNotDelete" ? "Cannot delete the resource or its child resources." : "Cannot delete or modify the resource or its child resources."
}

resource "azurerm_role_assignment" "this" {
  for_each = var.role_assignments

  principal_id                           = each.value.principal_id
  scope                                  = azurerm_resource_group.this.id
  condition                              = each.value.condition
  condition_version                      = each.value.condition_version
  delegated_managed_identity_resource_id = each.value.delegated_managed_identity_resource_id
  role_definition_id                     = strcontains(lower(each.value.role_definition_id_or_name), lower(local.role_definition_resource_substring)) ? each.value.role_definition_id_or_name : null
  role_definition_name                   = strcontains(lower(each.value.role_definition_id_or_name), lower(local.role_definition_resource_substring)) ? null : each.value.role_definition_id_or_name
  skip_service_principal_aad_check       = each.value.skip_service_principal_aad_check
}
