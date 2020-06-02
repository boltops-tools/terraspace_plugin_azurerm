module TerraspacePluginAzurerm::Clients
  module Options
    extend Memoist

    def client_options
      client_id       = ENV['AZURE_CLIENT_ID']
      client_secret   = ENV['AZURE_CLIENT_SECRET']
      subscription_id = ENV['AZURE_SUBSCRIPTION_ID'] || AzureInfo.subscription_id
      tenant_id       = ENV['AZURE_TENANT_ID'] || AzureInfo.tenant_id

      provider = MsRestAzure::ApplicationTokenProvider.new(tenant_id, client_id, client_secret)
      credentials = MsRest::TokenCredentials.new(provider)

      {
        tenant_id: tenant_id,
        client_id: client_id,
        client_secret: client_secret,
        subscription_id: subscription_id,
        credentials: credentials
      }
    end
  end
end
