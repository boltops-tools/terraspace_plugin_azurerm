class TerraspacePluginAzurerm::Interfaces::Backend
  class Base
    extend Memoist

    def initialize(info)
      @info = info
      @resource_group_name  = @info["resource_group_name"]
      @storage_account_name = @info["storage_account_name"]
      @container_name       = @info["container_name"]
    end

    def config
      TerraspacePluginAzurerm::Interfaces::Config.instance.config
    end

    def azure_info
      AzureInfo
    end
    memoize :azure_info

    def logger
      Terraspace.logger
    end
  end
end
