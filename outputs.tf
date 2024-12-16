output "name" {
  description = "The name of the Image Gallery."
  value       = azurerm_shared_image_gallery.this.name
}

output "resource_id" {
  description = "The id of the Image Gallery."
  value       = azurerm_shared_image_gallery.this.id
}
