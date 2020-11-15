require "base64"

module TerraspacePluginAzurerm::Interfaces::Helper
  class Secret
    extend Memoist
    include TerraspacePluginAzurerm::Logging
    include TerraspacePluginAzurerm::Clients::Options

    def initialize(options={})
      @options = options
      @base64 = options[:base64]
    end

    # opts: version, vault
    def fetch(name, opts={})
      value = fetcher.fetch(name, opts)
      value = Base64.strict_encode64(value).strip if @base64
      value
    end

    def fetcher
      Fetcher.new
    end
    memoize :fetcher
  end
end
