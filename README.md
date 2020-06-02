# Terraspace azurerm Cloud Plugin

azurerm Cloud support for [terraspace](https://terraspace.cloud/).

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
end
```

By default, this plugin will automatically create the:

* [resource group](Pluginazurerm)
* [storage account](https://docs.microsoft.com/en-us/azure/storage/common/storage-account-create?tabs=azure-portal)
* [storage container](https://docs.microsoft.com/en-us/cli/azure/storage/container?view=azure-cli-latest#az-storage-container-create)

The settings generally only apply if the resource does not yet exist yet and is created for the first time.

## Environment Variables

To create the Azure resources like [resource group](Pluginazurerm), [storage account](https://docs.microsoft.com/en-us/azure/storage/common/storage-account-create?tabs=azure-portal), and [storage container](https://docs.microsoft.com/en-us/cli/azure/storage/container?view=azure-cli-latest#az-storage-container-create) these environment variables are required:

    AZURE_CLIENT_ID
    AZURE_CLIENT_SECRET

There's other env variables can also be set, but are generally inferred.

    AZURE_TENANT_ID
    AZURE_SUBSCRIPTION_ID

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/boltops-tools/terraspace_plugin_azurerm.
