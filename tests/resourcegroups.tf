resource "azurerm_resource_group" "resourcegroup" {
  name     = "${var.PREFIX}"
  location = "${var.AZURE_REGION}"
}

output "resource_group_name" {
  value = "${azurerm_resource_group.resourcegroup.name}_NOT_SENSITIVE"
}

output "resource_group_name_sensitive" {
  value     = "${azurerm_resource_group.resourcegroup.name}_SENSITIVE"
  sensitive = true
}