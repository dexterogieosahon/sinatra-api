class ClientApplication < Sequel::Model
  many_to_one :user
  one_to_many :access_tokens

  def validate
    super
    validates_presence %i[name user_id]
    validates_unique :client_id
  end

  def before_create
    generate_tokens
    super
  end

  def authorize(secret)
    client_secret == secret
  end

  def elevated_privileges?
    in_house_app?
  end

  def generate_tokens
    self.client_id = SecureRandom.hex(32)
    self.client_secret = SecureRandom.hex(32)
  end
end
