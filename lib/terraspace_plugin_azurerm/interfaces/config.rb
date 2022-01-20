module TerraspacePluginAzurerm::Interfaces
  class Config
    include Terraspace::Plugin::Config::Interface
    include Singleton # Config class must be a Singleton with the class .instance method

    # interface method
    # load_project_config: config/plugins/azurerm.rb
    def provider
      "azurerm"
    end

    # interface method
    # must return an ActiveSupport::OrderedOptions
    def defaults
      c = ActiveSupport::OrderedOptions.new

      c.auto_create = true
      c.location = nil # AzureInfo.location not assigned here so it can be lazily inferred

      c.secrets = ActiveSupport::OrderedOptions.new
      c.secrets.vault = nil

      c.resource_group = ActiveSupport::OrderedOptions.new
      c.resource_group.update_existing = false

      c.storage_account = ActiveSupport::OrderedOptions.new
      c.storage_account.update_existing = false
      c.storage_account.sku = ActiveSupport::OrderedOptions.new
      c.storage_account.sku.name = "Standard_LRS"
      c.storage_account.sku.tier = "Standard"
      c.storage_account.allow_blob_public_access = false # Azure default is true

      # data protection management
      c.storage_account.configure_data_protection_for_existing = false
      c.storage_account.delete_retention_policy = ActiveSupport::OrderedOptions.new
      c.storage_account.delete_retention_policy.days = 365
      c.storage_account.delete_retention_policy.enabled = true
      # overrides the setting above
      c.storage_account.blob_delete_retention_policy = ActiveSupport::OrderedOptions.new
      c.storage_account.blob_delete_retention_policy.days = nil
      c.storage_account.blob_delete_retention_policy.enabled = nil
      c.storage_account.container_delete_retention_policy = ActiveSupport::OrderedOptions.new
      c.storage_account.container_delete_retention_policy.days = nil
      c.storage_account.container_delete_retention_policy.enabled = nil
      c.storage_account.is_versioning_enabled = true

      c.tags = {}

      c
    end
  end
end
