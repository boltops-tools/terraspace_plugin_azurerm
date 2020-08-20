# SUBSCRIPTION_HASH is a short 4-char consistent hash of the longer subscription id.
# This is useful because azure storage accounts not allowed special characters and can only be 24 chars long.
terraform {
  backend "azurerm" {
    resource_group_name  = "<%= expansion('terraform-resources-:LOCATION') %>"
    storage_account_name = "<%= expansion('ts:SUBSCRIPTION_HASH:LOCATION:ENV') %>"
    container_name       = "terraform-state"
    key                  = "<%= expansion(':LOCATION/:ENV/:BUILD_DIR/terraform.tfstate') %>"
  }
}
