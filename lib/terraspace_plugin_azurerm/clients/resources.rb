require 'azure_mgmt_resources'

module TerraspacePluginAzurerm::Clients
  module Resources
    include Options
    extend Memoist

    # Include SDK modules to ease access to Resources classes.
    include Azure::Resources::Profiles::Latest::Mgmt
    include Azure::Resources::Profiles::Latest::Mgmt::Models

    def mgmt
      Client.new(client_options)
    end
    memoize :mgmt
  end
end
