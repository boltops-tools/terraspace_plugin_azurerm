class TerraspacePluginAzurerm::Interfaces::Backend
  # Named ResourceGroupCreator to avoid collision with Azure ResourceGroup model
  class ResourceGroupCreator < Base
    include TerraspacePluginAzurerm::Clients::Resources

    def create
      if exist?
        puts "Resource Group #{@resource_group_name} already exists" if ENV['TS_LOUD']
      else
        create_resource_group
      end
    end

    def exist?
      resource_groups.check_existence(@resource_group_name)
    end

    def create_resource_group
      puts "Creating Resource Group #{@resource_group_name}..."
      resource_group = ResourceGroup.new
      resource_group.name = @resource_group_name
      resource_group.location = config.location || AzureInfo.location
      resource_groups.create_or_update(@resource_group_name, resource_group)
    end

  private
    def resource_groups
      ResourceGroups.new(mgmt)
    end
    memoize :resource_groups
  end
end
