require "net/http"

class TerraspacePluginAzurerm::Interfaces::Helper::Secret
  class Fetcher
    class Error < StandardError; end
    class VaultNotFoundError < Error; end
    class VaultNotConfiguredError < Error; end

    include TerraspacePluginAzurerm::Logging
    extend Memoist

    def initialize(mod, options={})
      @mod, @options = mod, options
    end

    def fetch(name, opts={})
      opts[:vault] ||= TerraspacePluginAzurerm.config.secrets.vault
      get_secret(name, opts)
    end

    def get_secret(name, options={})
      vault = options[:vault]
      check_vault_configured!(vault)
      version = options[:version]
      version = "/#{version}" if version
      name = expansion(name) if expand?
      secret.show(name: name, vault: vault)
    end

    def check_vault_configured!(vault)
      return if vault
      logger.error "ERROR: Vault has not been configured or vault option not passed in the azure_secret helper method.".color(:red)
      logger.error <<~EOL
        Please configure the Azure KeyVault you want to use.  Example:

        config/plugins/azurerm.rb

            TerraspacePluginAzurerm.configure do |config|
              config.secrets.vault = "REPLACE_WITH_YOUR_VAULT_NAME"
            end

        Docs: https://terraspace.cloud/docs/helpers/azure/secrets/
      EOL
      raise VaultNotConfiguredError.new
    end

  private
    def secret
      Armrest::Services::KeyVault::Secret.new
    end
    memoize :secret

    delegate :expansion, to: :expander
    def expander
      TerraspacePluginAzurerm::Interfaces::Expander.new(@mod)
    end
    memoize :expander

    def expand?
      !(@options[:expansion] == false || @options[:expand] == false)
    end
  end
end
