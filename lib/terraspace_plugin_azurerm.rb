require "armrest"
require "azure_info"
require "memoist"
require "terraspace" # for interface

require "terraspace_plugin_azurerm/version"
require "terraspace_plugin_azurerm/autoloader"
TerraspacePluginAzurerm::Autoloader.setup

module TerraspacePluginAzurerm
  class Error < StandardError; end

  # Friendlier method for config/plugins/azurerm.rb. Example:
  #
  #     TerraspacePluginAzurerm.configure do |config|
  #       config.resource.property = "value"
  #     end
  #
  def configure(&block)
    Interfaces::Config.instance.configure(&block)
  end

  def config
    Interfaces::Config.instance.config
  end

  @@logger = nil
  def logger
    @@logger ||= Terraspace.logger
  end

  def logger=(v)
    @@logger = v
  end

  extend self
end

Terraspace::Plugin.register("azurerm",
  backend: "azurerm",
  config_class: TerraspacePluginAzurerm::Interfaces::Config,
  helper_class: TerraspacePluginAzurerm::Interfaces::Helper,
  layer_class: TerraspacePluginAzurerm::Interfaces::Layer,
  ci_class: TerraspacePluginAzurerm::Interfaces::Ci,
  root: File.dirname(__dir__),
)
