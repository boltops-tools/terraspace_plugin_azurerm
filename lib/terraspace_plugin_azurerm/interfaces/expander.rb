require 'digest/sha1'

# This is where you define variable substitions for the Terraspace expander.
# Methods are available as variables.  For example:
#
#    variable          | method
#    ------------------|--------
#    :LOCATION         | location
#    :SUSCRIPTION      | suscription
#    :SUSCRIPTION_HASH | suscription_hash
#    :NAMESPACE_HASH   | namespace_hash
#
module TerraspacePluginAzurerm::Interfaces
  class Expander
    include Terraspace::Plugin::Expander::Interface

    delegate :subscription_id, :subscription, :tenant_id, :tenant_id, :group, :location, to: :azure_info
    alias_method :namespace, :subscription
    alias_method :region, :location

    def azure_info
      AzureInfo
    end

    # subscription_hash is a short 4-char consistent hash of the longer subscription id.
    # This is useful because azure storage account names are not allowed special characters and are limited to 24 chars.
    # NOTE: be careful to not change this! or else state path will change
    def subscription_hash
      Digest::SHA1.hexdigest(subscription)[0..3]
    end
    alias_method :namespace_hash, :subscription_hash

    # location_hash is a short 4-char consistent hash of the longer subscription id.
    # This is useful because azure storage account names are not allowed special characters and are limited to 24 chars.
    # NOTE: be careful to not change this! or else state path will change
    def location_hash
      Digest::SHA1.hexdigest(location)[0..3]
    end
    alias_method :region_hash, :location_hash

    def app_hash
      Digest::SHA1.hexdigest(ENV['TS_APP'])[0..3] if ENV['TS_APP']
    end

    def env_hash
      Digest::SHA1.hexdigest(ENV['TS_ENV'])[0..3] if ENV['TS_ENV']
    end
  end
end
