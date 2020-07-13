require 'azure/storage/blob'

module TerraspacePluginAzurerm::Interfaces
  class Summary
    include Terraspace::Plugin::Summary::Interface
    extend Memoist

    # interface method
    def bucket_field
      'storage_account_name'
    end

    # interface method
    def download
      container_name = @info['container_name']

      marker = nil
      loop do
        blobs = blob_client.list_blobs(container_name, marker: marker)
        blobs.each do |blob|
          blob, content = blob_client.get_blob(container_name, blob.name)
          local_path = "#{@dest}/#{blob.name}"
          FileUtils.mkdir_p(File.dirname(local_path))
          File.open(local_path, 'wb') {|f| f.write(content)}
        end
        marker = blobs.continuation_token
        break unless marker && !marker.empty?
      end
    end

    # override default since azure statefiles do not have .tfstate extension
    # interface method
    def statefile_expr
      "#{@dest_folder}**/*"
    end

  private
    def blob_client
      Azure::Storage::Blob::BlobService.create(
        storage_account_name: ENV['AZURE_STORAGE_ACCOUNT'],
        storage_access_key: ENV['AZURE_STORAGE_KEY']
      )
    end
    memoize :blob_client
  end
end
