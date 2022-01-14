class TerraspacePluginAzurerm::Interfaces::Backend
  class BlobContainer < Base
    def create
      if exist?
        logger.debug "Storage Blob Container #{@container_name} already exists"
      else
        create_blob_container
      end
    end

    def exist?
      blob_container.exist?(name: @container_name)
    end

    def create_blob_container
      logger.info "Creating Storage Blob Container #{@container_name}..."
      blob_container.create(name: @container_name)
    end

   private
    def blob_container
      Armrest::Services::BlobContainer.new(storage_account: @storage_account_name, group: @resource_group_name)
    end
    memoize :blob_container
  end
end
