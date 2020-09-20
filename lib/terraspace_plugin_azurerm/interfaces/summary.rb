require 'azure/storage/blob'

module TerraspacePluginAzurerm::Interfaces
  class Summary
    include Terraspace::Plugin::Summary::Interface
    include TerraspacePluginAzurerm::Clients::Storage # for mgmt storage_accounts to get keys only, the azure/storage/blob gem is used to get the objects
    extend Memoist

    # interface method
    def bucket_field
      'storage_account_name'
    end

    # interface method
    def download
      marker = nil
      loop do
        blobs = list_blobs(container_name, marker: marker)
        blobs.each do |blob|
          blob, content = blob_client.get_blob(container_name, blob.name)
          local_path = "#{@dest}/#{blob.name}"
          FileUtils.mkdir_p(File.dirname(local_path))
          File.open(local_path, 'wb') {|f| f.write(content)}
        end
        marker = blobs.continuation_token
        break unless marker && !marker.empty?
      end
    end

    # interface method
    def delete_empty_statefile(key)
      delete_blob(key)
    end

    def delete_blob(key)
      blob_client.delete_blob(container_name, key)
    rescue Azure::Core::Http::HTTPError => e
      case e.message
      when /BlobNotFound/
        logger.info "WARN: #{e.class}: #{e.message}"
        logger.info "Blob item does not exist: #{key}"
      when /ContainerNotFound/
        logger.info "WARN: #{e.class}: #{e.message}"
        logger.info "Container not found: #{container_name}"
      else
        raise
      end
    end

    def container_name
      @info['container_name']
    end

    # Friendly error handling for user
    def list_blobs(container_name, marker:)
      blob_client.list_blobs(container_name, marker: marker, prefix: @folder)
    rescue Azure::Core::Http::HTTPError => e
      if e.message.include?("AuthenticationFailed")
        logger.error "e.class #{e.class}: #{e.message}"
        logger.error "Unable to authenticate to download the statefiles from the storage account.".color(:red)
        if ENV['AZURE_STORAGE_ACCESS_KEY']
          logger.error <<~EOL
            It looks like you have the AZURE_STORAGE_ACCESS_KEY environment variable set.
            It may be the incorrect key for the storage account: #{@info['storage_account_name']}
            Try unsetting it:

                unset AZURE_STORAGE_ACCESS_KEY

            When the environment variable is not set, this library will try to fetch the key for you.
            Or you can try setting the correct key.
          EOL
        else
          logger.error <<~EOL
            The fetched storage access key did not seem to authenticate successfully.
            Try setting the AZURE_STORAGE_ACCESS_KEY environment variable with access to the storage account: #{@info['storage_account_name']}
          EOL
        end
        # Common message
        logger.error <<~EOL
          One way to get the key is with:

              az storage account keys list --account-name #{@info['storage_account_name']} --resource-group #{@info['resource_group_name']}

          Then you can set it:

              export AZURE_STORAGE_ACCESS_KEY=[replace-with-value]
        EOL
        exit 1
      else
        raise
      end
    end

  private
    def blob_client
      # Note per docs: https://github.com/azure/azure-storage-ruby/tree/master/blob#via-environment-variables
      #
      #     export AZURE_STORAGE_ACCOUNT = <your azure storage account name>
      #     export AZURE_STORAGE_ACCESS_KEY = <your azure storage access key>
      #
      # Works if zero args are passed to the create method. But set the storage_account_name arg, so we must also set
      # the storage_access_key explicitly. We'll follow the same env variable convention.
      #
      Azure::Storage::Blob::BlobService.create(
        storage_account_name: @info['storage_account_name'],
        storage_access_key: storage_access_key
      )
    end
    memoize :blob_client

    def storage_access_key
      ENV['AZURE_STORAGE_ACCESS_KEY'] || fetch_storage_access_key
    end

    def fetch_storage_access_key
      # result is a StorageAccountListKeysResult with a keys reader method
      # then .value contains the key
      result = storage_accounts.list_keys(@info['resource_group_name'], @info['storage_account_name'])
      result.keys.first.value
    end
  end
end
