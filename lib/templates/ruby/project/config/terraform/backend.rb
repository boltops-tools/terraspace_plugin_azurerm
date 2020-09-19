# SUBSCRIPTION_HASH is a short 4-char consistent hash of the longer subscription id.
# This is useful because azure storage account names are not allowed special characters and are limited to 24 chars.
backend("azurerm",
  resource_group_name:  "terraform-resources-:LOCATION",
  storage_account_name: "ts:SUBSCRIPTION_HASH:LOCATION:ENV",
  container_name:       "terraform-state",
  key:                  ":LOCATION/:ENV/:BUILD_DIR/terraform.tfstate",
)
