module TerraspacePluginAzurerm::Interfaces
  class Layer
    extend Memoist

    # interface method
    def namespace
      AzureInfo.subscription_id
    end

    # interface method
    def region
      AzureInfo.location
    end

    # interface method
    def provider
      "azurerm"
    end
  end
end
