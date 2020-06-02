module TerraspacePluginAzurerm::Interfaces
  class Config
    include Terraspace::Plugin::Config::Interface
    include Singleton # Config class must be a Singleton with the class .instance method

    def provider
      "azurerm"
    end

    # interface method
    # must return an ActiveSupport::OrderedOptions
    def defaults
      c = ActiveSupport::OrderedOptions.new
      c.auto_create = true
      c.location = nil # AzureInfo.location not assigned here so it can be lazily inferred

      c.storage_account = ActiveSupport::OrderedOptions.new
      c.storage_account.sku = ActiveSupport::OrderedOptions.new
      c.storage_account.sku.name = "Standard_LRS"
      c.storage_account.sku.tier = "Standard"

      c
    end
  end
end
