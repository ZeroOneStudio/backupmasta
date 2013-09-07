class User
  include DataMapper::Resource

  property :id,         Serial
  property :uid,        String
  property :name,       String
  property :nickname,   String
  property :email,      String
  property :created_at, DateTime

  has n, :backups

  def self.create_from_omniauth auth
    User.first_or_create(
      { 
        uid: auth["uid"] 
      }, 
      {
        name: auth["info"]["name"], 
        nickname: auth["info"]["nickname"], 
        email: auth["info"]["email"], 
        created_at: Time.now 
      }
    )
  end
end