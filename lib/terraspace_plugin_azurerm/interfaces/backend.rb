module TerraspacePluginAzurerm::Interfaces
  class Backend
    include Terraspace::Plugin::Backend::Interface

    # interface method
    def call
      return unless Config.instance.config.auto_create

      ResourceGroupCreator.new(@info).create
      StorageAccount.new(@info).create
      StorageContainer.new(@info).create
    end
  end
end
