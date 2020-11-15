module TerraspacePluginAzurerm::Interfaces
  module Helper
    include Terraspace::Plugin::Helper::Interface

    def azure_secret(name, options={})
      Secret.new(options).fetch(name, options)
    end
    cache_helper :azure_secret
  end
end
