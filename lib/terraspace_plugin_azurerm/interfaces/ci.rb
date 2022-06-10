module TerraspacePluginAzurerm::Interfaces
  class Ci
    # interface method
    def vars
      {
        ARM_SUBSCRIPTION_ID: '${{ secrets.ARM_SUBSCRIPTION_ID }}',
        ARM_CLIENT_SECRET: '${{ secrets.ARM_CLIENT_SECRET }}',
        ARM_TENANT_ID: '${{ secrets.ARM_TENANT_ID }}',
        ARM_CLIENT_ID: '${{ secrets.ARM_CLIENT_ID }}',
      }
    end
  end
end
