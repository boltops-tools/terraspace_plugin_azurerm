module TerraspacePluginAzurerm::Interfaces
  class Layer
    extend Memoist
    include Terraspace::Plugin::Layer::Interface

    # interface method
    def namespace
      AzureInfo.subscription_id
    end

    # interface method
    def region
      AzureInfo.location
    end
  end
end
