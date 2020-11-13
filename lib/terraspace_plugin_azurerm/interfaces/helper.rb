module TerraspacePluginAzurerm::Interfaces
  module Helper
    def azure_secret(name, options={})
      Secret.new(options).fetch(name, options)
    end
  end
end
