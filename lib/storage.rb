class Storage
  class << self; alias :connect :new; end
  
  attr_writer :name

  def initialize
    connection = Fog::Storage.new({ 
      provider: 'Google', 
      google_storage_access_key_id: ENV['GOOGLE_STORAGE_ID'], 
      google_storage_secret_access_key: ENV['GOOGLE_STORAGE_SECRET']
    })
    @directories = connection.directories
  end

  def create
    @directories.create({key: "backupmasta-#{@name}-#{Sinatra::Base.environment}"})
  end

  def destroy
    dir = current_directory
    dir.files.map(&:destroy)
    dir.destroy
  end

  def files
    current_directory.files
  end

  private

  def current_directory
    @directories.get("backupmasta-#{@name}-#{Sinatra::Base.environment}")
  end
end