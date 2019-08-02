resource "azurerm_container_registry" "containerregistry" {
  name                = "${var.PREFIX} container registry"
  resource_group_name = "${azurerm_resource_group.resourcegroup.name}"
  location            = "${var.AZURE_REGION}"
  sku                 = "basic"
  admin_enabled       = true
}

output "container_registry_admin_username" {
  value     = "${azurerm_container_registry.containerregistry.admin_username}"
  sensitive = true
}

output "container_registry_admin_password" {
  value     = "${azurerm_container_registry.containerregistry.admin_password}"
  sensitive = true
}