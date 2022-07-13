# Backend Config Variables Docs
# https://terraspace.cloud/docs/config/backend/variables/
#
# SUBSCRIPTION_HASH is a short 4-char consistent hash of the longer subscription id.
# LOCATION_HASH is a short 4-char consistent hash of the longer location.
# This is useful because azure storage account names are not allowed special characters and are limited to 24 chars.
terraform {
  backend "azurerm" {
    resource_group_name  = "<%= expansion(':APP-:ENV-:LOCATION') %>"
    storage_account_name = "<%= expansion('ts:APP_HASH:SUBSCRIPTION_HASH:LOCATION_HASH:ENV') %>"
    container_name       = "terraform-state"
    key                  = "<%= expansion(':PROJECT/:TYPE_DIR/:APP/:ROLE/:MOD_NAME/:ENV/:EXTRA/:LOCATION/terraform.tfstate') %>"
  }
}
