require "azure_mgmt_storage"

module TerraspacePluginAzurerm::Clients
  module Storage
    include Options
    extend Memoist

    # Include SDK modules to ease access to Storage classes.
    include Azure::Storage::Mgmt::V2019_06_01
    include Azure::Storage::Mgmt::V2019_06_01::Models

    def storage_accounts
      mgmt.storage_accounts
    end

    def blob_containers
      BlobContainers.new(mgmt)
    end
    memoize :blob_containers

    def mgmt
      client = StorageManagementClient.new(credentials)
      client.subscription_id = client_options[:subscription_id]
      client
    end
    memoize :mgmt
  end
end
