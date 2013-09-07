class Storage
  class << self
    def connect
      Fog::Storage.new({
        provider:                         'Google',
        google_storage_access_key_id:     Storage.credentials['key'],
        google_storage_secret_access_key: Storage.credentials['secret']
      })
    end

    alias :connection :connect

    def credentials
      JSON.parse(File.read("data/credentials.json"))
    end

    def directory
      self.connection.directories.get("backupmasta")
    end

    def files
      directory.files
    end
  end
end