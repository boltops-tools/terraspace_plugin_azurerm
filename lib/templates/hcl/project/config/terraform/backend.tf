# SUBSCRIPTION_HASH is a short 4-char consistent hash of the longer subscription id.
# This is useful because azure storage accounts not allowed special characters and can only be 24 chars long.
terraform {
  backend "azurerm" {
    resource_group_name  = "<%= backend_expand('azurerm', 'terraform-resources-:LOCATION') %>"
    storage_account_name = "<%= backend_expand('azurerm', 'ts:SUBSCRIPTION_HASH:LOCATION:ENV') %>"
    container_name       = "terraform-state"
    key                  = "<%= backend_expand('azurerm', ':LOCATION/:ENV/:BUILD_DIR/terraform.tfstate') %>"
  }
}
