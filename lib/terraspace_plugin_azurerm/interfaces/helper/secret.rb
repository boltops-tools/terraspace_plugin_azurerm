require "base64"

module TerraspacePluginAzurerm::Interfaces::Helper
  class Secret
    extend Memoist
    include TerraspacePluginAzurerm::Logging
    include TerraspacePluginAzurerm::Clients::Options

    def initialize(mod, options={})
      @mod, @options = mod, options
      @base64 = options[:base64]
    end

    # opts: version, vault
    def fetch(name, opts={})
      value = fetcher.fetch(name, opts)
      value = Base64.strict_encode64(value).strip if @base64
      value
    end

    def fetcher
      Fetcher.new(@mod, @options)
    end
    memoize :fetcher
  end
end
