require "net/http"

class TerraspacePluginAzurerm::Interfaces::Helper::Secret
  class Fetcher
    class Error < StandardError; end
    class VaultNotFoundError < Error; end

    include TerraspacePluginAzurerm::Logging
    include TerraspacePluginAzurerm::Clients::Options

    def initialize
      o = base_client_options
      @client_id     = o[:client_id]
      @client_secret = o[:client_secret]
      @tenant_id     = o[:tenant_id]
    end

    def fetch(name, opts={})
      opts[:vault] ||= TerraspacePluginAzurerm.config.secrets.vault
      get_secret(name, opts)
    end

    def get_secret(name, vault: nil, version: nil)
      unless token
        return "ERROR: Unable to authorize and get the temporary token. Double check your ARM_ env variables."
      end

      version = "/#{version}" if version
      vault_subdomain = vault.downcase
      # Using Azure REST API since the old gem doesnt support secrets https://github.com/Azure/azure-sdk-for-ruby
      # https://docs.microsoft.com/en-us/rest/api/keyvault/getsecret/getsecret
      url = "https://#{vault_subdomain}.vault.azure.net/secrets/#{name}#{version}?api-version=7.1"
      uri = URI(url)
      req = Net::HTTP::Get.new(uri)
      req["Authorization"] = token
      req["Content-Type"] = "application/json"

      resp = nil
      begin
        resp = send_request(uri, req)
      rescue VaultNotFoundError
        message = "WARN: Vault not found #{vault}"
        logger.info message.color(:yellow)
        return message
      end

      case resp.code.to_s
      when /^2/
        data = JSON.load(resp.body)
        data['value']
      else
        message = standard_error_message(resp)
        logger.info "WARN: #{message}".color(:yellow)
        message
      end
    end

    def send_request(uri, req)
      http = Net::HTTP.new(uri.host, uri.port)
      http.open_timeout = http.read_timeout = 30
      http.use_ssl = true if uri.scheme == 'https'

      begin
        http.request(req) # response
      rescue SocketError => e
        # SocketError: Failed to open TCP connection to MISSING-VAULT.vault.azure.net:443 (getaddrinfo: Name or service not known)
        if e.message.include?("vault.azure.net")
          raise VaultNotFoundError.new(e)
        else
          raise
        end
      end
    end

    # Secret error handling: 1. network 2. json parse 3. missing secret
    #
    # Azure API responses with decent error message when
    #   403 Forbidden - KeyVault Access Policy needs to be set up
    #   404 Not Found - Secret name is incorrect
    #
    def standard_error_message(resp)
      data = JSON.load(resp.body)
      data['error']['message']
    rescue JSON::ParserError
      resp.body
    end

    @@token = nil
    def token
      return @@token unless @@token.nil?
      url = "https://login.microsoftonline.com/#{@tenant_id}/oauth2/token"
      uri = URI(url)
      req = Net::HTTP::Get.new(uri)
      req.set_form_data(
        grant_type: "client_credentials",
        client_id: @client_id,
        client_secret: @client_secret,
        resource: "https://vault.azure.net",
      )
      resp = send_request(uri, req)
      data = JSON.load(resp.body)
      if resp.code =~ /^2/
        @@token = "Bearer #{data['access_token']}" if data
      else
        logger.info "WARN: #{data['error_description']}".color(:yellow)
        # return false otherwise error message is used as the bearer toke and get this error:
        # ArgumentError: header field value cannot include CR/LF
        @@token = false
      end
    end
  end
end
