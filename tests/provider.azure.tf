provider "azurerm" {
  subscription_id = "${var.AZURE_SUBSCRIPTION_ID}"
  client_id       = "${var.AZURE_CLIENT_ID}"
  client_secret   = "${var.AZURE_CLIENT_SECRET}"
  tenant_id       = "${var.AZURE_TENANT_ID}"
}

terraform {
  required_version = ">= 0.11.11"
}