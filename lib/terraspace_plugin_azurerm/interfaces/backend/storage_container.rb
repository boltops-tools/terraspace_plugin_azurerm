class TerraspacePluginAzurerm::Interfaces::Backend
  class StorageContainer < Base
    include TerraspacePluginAzurerm::Clients::Storage

    def create
      if exist?
        logger.debug "Storage Container #{@container_name} already exists"
      else
        create_storage_container
      end
    end

    def exist?
      begin
        blob_containers.get(@resource_group_name, @storage_account_name, @container_name)
        true
      rescue MsRestAzure::AzureOperationError => e
        e.message.include?("The specified container does not exist") ? false : raise
      end
    end

    def create_storage_container
      logger.info "Creating Storage Container #{@container_name}..."
      blob_container = BlobContainer.new
      blob_container.name = @container_name
      blob_containers.create(@resource_group_name, @storage_account_name, @container_name, blob_container)
    end
  end
end
