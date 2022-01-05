class TerraspacePluginAzurerm::Interfaces::Backend
  class StorageAccount < Base
    include TerraspacePluginAzurerm::Clients::Storage
    extend Memoist

    def create
      if exist?
        logger.debug "Storage Account #{@storage_account_name} already exists"
      else
        create_storage_account
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

    def create_storage_account
      logger.info "Creating Storage Account #{@storage_account_name}..."
      storage_accounts.create(@resource_group_name, @storage_account_name, storage_account_params)
    end

    def storage_account_params
      params = StorageAccountCreateParameters.new
      params.location = config.location || azure_info.location # IE: eastus
      params.sku = sku
      params.kind = Kind::StorageV2
      params.tags = config.tags
      params
    end

    def sku
      sku = Sku.new
      sku.name = config.storage_account.sku.name
      sku.tier = config.storage_account.sku.tier
      sku
    end
  end
end
