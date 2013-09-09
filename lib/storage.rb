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

    attr_accessor :name

    def create
      self.connection.directories.create({key: "backupmasta-#{name}"})
    end

    def get_directory
      self.connection.directories.get("backupmasta-#{name}")
    end

    def files
      get_directory.files
    end
  end
end
