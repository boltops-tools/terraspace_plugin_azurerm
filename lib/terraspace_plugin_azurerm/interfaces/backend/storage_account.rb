class TerraspacePluginAzurerm::Interfaces::Backend
  class StorageAccount < Base
    extend Memoist

    def create
      if exist?
        logger.debug "Storage Account #{@storage_account_name} already exists"
        save_storage_account if config.storage_account.update_existing
        set_blob_service_properties if config.storage_account.configure_data_protection_for_existing
      else
        save_storage_account
        set_blob_service_properties
      end
    end

    def exist?
      result = storage_account.check_name_availability(name: @storage_account_name)
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

    def save_storage_account
      action = exist? ? "Updating" : "Creating"
      logger.info "#{action} Storage Account #{@storage_account_name}..."
      storage_account.create(
        name: @storage_account_name,
        location: config.location || azure_info.location, # IE: eastus
        sku: {
          name: config.storage_account.sku.name,
          tier: config.storage_account.sku.tier,
        },
        properties: {
          allowBlobPublicAccess: config.storage_account.allow_blob_public_access,
        },
        kind: "StorageV2",
        tags: config.tags,
      )
    end

    def set_blob_service_properties
      blob_service.set_properties(blob_service_properties)
    end

    def blob_service_properties
      sa = config.storage_account
      container_delete_retention_policy = {
        days: sa.container_delete_retention_policy.days || sa.delete_retention_policy.days,
        enabled: sa.container_delete_retention_policy.enabled || sa.delete_retention_policy.enabled,
      }
      # blobs
      delete_retention_policy = {
        days: sa.blob_delete_retention_policy.days || sa.delete_retention_policy.days,
        enabled: sa.blob_delete_retention_policy.enabled || sa.delete_retention_policy.enabled,
      }
      # final props
      {
        containerDeleteRetentionPolicy: container_delete_retention_policy,
        deleteRetentionPolicy: delete_retention_policy,
        isVersioningEnabled: sa.is_versioning_enabled,
      }
    end

  private
    def storage_account
      Armrest::Services::StorageAccount.new(service_options)
    end
    memoize :storage_account

    def blob_service
      Armrest::Services::BlobService.new(service_options)
    end
    memoize :blob_service

    def service_options
      { storage_account: @storage_account_name, group: @resource_group_name }
    end
  end
end
