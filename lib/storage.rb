class Storage
  class << self
    def connect
      Fog::Storage.new({
        provider:                         'Google',
        google_storage_access_key_id:     ENV['GOOGLE_STORAGE_ID'],
        google_storage_secret_access_key: ENV['GOOGLE_STORAGE_SECRET']
      })
    end

    alias :connection :connect

    def directory
      self.connection.directories.get("backupmasta")
    end

    def files
      directory.files
    end
  end
end
