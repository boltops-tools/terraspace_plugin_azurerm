require "azure_mgmt_storage"

module TerraspacePluginAzurerm::Clients
  module Storage
    include Options
    extend Memoist

    # Include SDK modules to ease access to Storage classes.
    include Azure::Storage::Profiles::Latest::Mgmt
    include Azure::Storage::Profiles::Latest::Mgmt::Models

    def storage_accounts
      mgmt.storage_accounts
    end

    def blob_containers
      BlobContainers.new(mgmt)
    end
    memoize :blob_containers

    def mgmt
      Client.new(client_options)
    end
    memoize :mgmt
  end
end
