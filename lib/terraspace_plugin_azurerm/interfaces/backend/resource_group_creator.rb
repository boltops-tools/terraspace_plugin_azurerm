class TerraspacePluginAzurerm::Interfaces::Backend
  # Named ResourceGroupCreator to avoid collision with Azure ResourceGroup model
  class ResourceGroupCreator < Base
    def create
      if exist?
        logger.debug "Resource Group #{@resource_group_name} already exists"
        create_or_update_resource_group if config.resource_group.update_existing
      else
        create_or_update_resource_group
      end
    end

    def exist?
      resource_group.check_existence(name: @resource_group_name)
    end

    def create_or_update_resource_group
      logger.info "Creating Resource Group #{@resource_group_name}..."
      resource_group.create_or_update(
        name: @resource_group_name,
        location: config.location || AzureInfo.location,
        tags: config.tags,
      )
    end

  private
    def resource_group
      Armrest::Services::ResourceGroup.new
    end
    memoize :resource_group
  end
end
