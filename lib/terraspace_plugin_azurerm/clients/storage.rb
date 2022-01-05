require "azure_mgmt_storage"

module TerraspacePluginAzurerm::Clients
  module Storage
    include Options
    extend Memoist

    # Include SDK modules to ease access to Storage classes.
    include Azure::Storage::Profiles::Latest::Mgmt
    include Azure::Storage::Profiles::Latest::Mgmt::Models

    delegate :storage_accounts, :blob_services, :blob_containers, to: :mgmt

    def blob_containers
      BlobContainers.new(mgmt)
    end
    memoize :blob_containers

    def mgmt
      client = Client.new(client_options)
      client.subscription_id = client_options[:subscription_id]
      client
    end
    memoize :mgmt
  end
end
