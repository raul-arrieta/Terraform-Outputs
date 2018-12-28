resource "azurerm_resource_group" "resourcegroup" {
  name     = "${var.PREFIX}"
  location = "${var.AZURE_REGION}"
}

output "resource_group_name" {
  value = "${azurerm_resource_group.resourcegroup.name}"
}