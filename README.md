# Terraspace Azurerm Plugin

Azurerm support for [terraspace](https://terraspace.cloud/).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'terraspace_plugin_azurerm'
```

## Configure

Optionally configure the plugin. Here's an example `azurerm.rb` for your terraspace project.

config/plugins/azurerm.rb

```ruby
TerraspacePluginAzurerm.configure do |config|
  config.auto_create = true # set false to disable auto creation

  config.storage_account.sku.name = "Standard_LRS"
  config.storage_account.sku.tier = "Standard"

  config.tags = {env: Terraspace.env, terraspace: true}
end
```

By default, this plugin will automatically create the:

* [resource group](https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/manage-resource-groups-portal)
* [storage account](https://docs.microsoft.com/en-us/azure/storage/common/storage-account-create?tabs=azure-portal)
* [storage container](https://docs.microsoft.com/en-us/cli/azure/storage/container?view=azure-cli-latest#az-storage-container-create)

The settings generally only apply if the resource does not yet exist yet and is created for the first time.

## Environment Variables

To create the Azure resources like [resource group](https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/manage-resource-groups-portal), [storage account](https://docs.microsoft.com/en-us/azure/storage/common/storage-account-create?tabs=azure-portal), and [storage container](https://docs.microsoft.com/en-us/cli/azure/storage/container?view=azure-cli-latest#az-storage-container-create) these environment variables are required:

    ARM_CLIENT_ID
    ARM_CLIENT_SECRET

Other env variables can be optionally set:

    ARM_TENANT_ID
    ARM_SUBSCRIPTION_ID

When not set, their values are inferred from the [az cli](https://docs.microsoft.com/en-us/cli/azure/) settings. For those interested, this is done with the [boltops-tools/azure_info](https://github.com/boltops-tools/azure_info) library.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/boltops-tools/terraspace_plugin_azurerm.
