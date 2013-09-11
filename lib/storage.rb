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
      connection.directories.create({key: "backupmasta-#{name}-#{Sinatra::Base.environment}"})
    end

    def destroy
      begin
        get_directory.files.map(&:destroy)
        get_directory.destroy
      rescue
        return
      end
    end

    def get_directory
      connection.directories.get("backupmasta-#{name}-#{Sinatra::Base.environment}")
    end

    def files
      get_directory.files
    end
  end
end
