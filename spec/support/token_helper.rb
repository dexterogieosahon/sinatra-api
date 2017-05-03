module TokenHelper
  def get_jwt(payload)
    JWT.encode(payload, ENV["JWT_SECRET_KEY"], "HS512")
  end
end

RSpec.configure do |config|
  config.include TokenHelper
end
