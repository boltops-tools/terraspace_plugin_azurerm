class TerraspacePluginAzurerm::Interfaces::Backend
  class StorageAccount < Base
    include TerraspacePluginAzurerm::Clients::Storage
    extend Memoist

    def create
      if exist?
        logger.debug "Storage Account #{@storage_account_name} already exists"
        update_storage_account if config.storage_account.update_existing
        set_blob_service_properties if config.storage_account.configure_data_protection_for_existing
      else
        create_storage_account
        set_blob_service_properties
      end
    end

    def exist?
      params = StorageAccountCheckNameAvailabilityParameters.new
      params.name = @storage_account_name
      result = storage_accounts.check_name_availability(params)
      validate!(result)
      !result.name_available
    end

    def validate!(result)
      return true if result.name_available

      case result.reason
      when "AccountNameInvalid"
        logger.error "ERROR: Failed to create storage account, reason: #{result.reason}".color(:red)
        logger.error "Provided storage_account_name: #{@storage_account_name}"
        exit 1
      else
        false
      end
    end

    def update_storage_account
      logger.debug "Updating Storage Account #{@storage_account_name}..."
      storage_accounts.update(@resource_group_name, @storage_account_name, storage_account_update_params)
    end

    def create_storage_account
      logger.info "Creating Storage Account #{@storage_account_name}..."
      storage_accounts.create(@resource_group_name, @storage_account_name, storage_account_create_params)
    end

    def storage_account_create_params
      params = StorageAccountCreateParameters.new
      params.location = config.location || azure_info.location # IE: eastus
      params.sku = sku
      params.allow_blob_public_access = config.storage_account.allow_blob_public_access
      params.kind = Kind::StorageV2
      params.tags = config.tags
      params
    end

    def storage_account_update_params
      params = StorageAccountUpdateParameters.new
      params.allow_blob_public_access = config.storage_account.allow_blob_public_access
      params
    end

    def sku
      sku = Sku.new
      sku.name = config.storage_account.sku.name
      sku.tier = config.storage_account.sku.tier
      sku
    end

    def set_blob_service_properties
      blob_services.set_service_properties(@resource_group_name, @storage_account_name, blob_service_properties)
    end

    def blob_service_properties
      props = BlobServiceProperties.new

      sa = config.storage_account
      policy = DeleteRetentionPolicy.new
      policy.days = sa.container_delete_retention_policy.days || sa.delete_retention_policy.days
      policy.enabled = sa.container_delete_retention_policy.enabled || sa.delete_retention_policy.enabled
      props.container_delete_retention_policy = policy # containers

      policy = DeleteRetentionPolicy.new
      policy.days = sa.blob_delete_retention_policy.days || sa.delete_retention_policy.days
      policy.enabled = sa.blob_delete_retention_policy.enabled || sa.delete_retention_policy.enabled
      props.delete_retention_policy = policy # blobs

      props.is_versioning_enabled = sa.is_versioning_enabled
      props
    end
  end
end
