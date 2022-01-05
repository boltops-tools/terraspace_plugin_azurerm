module TerraspacePluginAzurerm::Clients
  module Options
    extend Memoist

    def client_options
      # AZURE_* is used by ruby generally.
      # ARM_* is used by Terraform azurerm provider: https://www.terraform.io/docs/providers/azurerm/index.html
      # Favor ARM_ because this plugin is designed for Terraspace.
      client_id       = ENV['ARM_CLIENT_ID'] || ENV['AZURE_CLIENT_ID']
      client_secret   = ENV['ARM_CLIENT_SECRET'] || ENV['AZURE_CLIENT_SECRET']
      subscription_id = ENV['ARM_SUBSCRIPTION_ID'] || ENV['AZURE_SUBSCRIPTION_ID'] || AzureInfo.subscription_id
      tenant_id       = ENV['ARM_TENANT_ID'] || ENV['AZURE_TENANT_ID'] || AzureInfo.tenant_id

      o = {
        tenant_id: tenant_id,
        client_id: client_id,
        client_secret: client_secret,
        subscription_id: subscription_id,
      }
      validate_base_options!(o)
      o
    end
    memoize :client_options

    def validate_base_options!(options)
      vars = []
      options.each do |k,v|
        vars << "ARM_#{k}".upcase if v.nil?
      end
      return if vars.empty?

      logger.error "ERROR: Required Azure env variables missing. Please set these env variables:".color(:red)
      vars.each do |var|
        logger.error "    #{var}"
      end
      exit 1
    end
  end
end
