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
    # This is useful because azure storage accounts not allowed special characters and can only be 24 chars long.
    # NOTE: be careful to not change this! or else state path will change
    def subscription_hash
      Digest::SHA1.hexdigest(subscription)[0..3]
    end
    alias_method :namespace_hash, :subscription_hash
  end
end
