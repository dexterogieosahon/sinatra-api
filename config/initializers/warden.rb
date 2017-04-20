require 'base64'

Warden::Manager.before_failure do |env,opts|
  # Sinatra is very sensitive to the request method
  # since authentication could fail on any type of method, we need
  # to set it for the failure app so it is routed to the correct block
  env['REQUEST_METHOD'] = "POST"
end

Warden::Strategies.add(:client_id) do
  def valid?
    params['client_id']
  end

  def authenticate!
    client = ClientApplication.find(client_id: params['client_id'])
    if client.nil?
      throw(:warden, message: "Could not find client")
    else
      env['warden.oauth_client'] = client
      success!(AccessToken.for_client(client))
    end
  end
end

Warden::Strategies.add(:client_secret) do
  def valid?
    request.env['warden.api.error'] = "You must provide client id and secret"
    client_from_header || client_from_body
  end

  def authenticate!
    credentials = client_from_header || client_from_body

    client = ClientApplication.find(client_id: credentials[:client_id], client_secret: credentials[:client_secret])

    if client.nil?
      throw(:warden, message: "Could not find client")
    else
      env['warden.oauth_client'] = client
      success!(AccessToken.for_client(client))
    end
  end

  def client_from_header
    return nil if env['HTTP_AUTHORIZATION'].nil?
    enc = env['HTTP_AUTHORIZATION'].sub(/^Basic/, "").strip
    plain = Base64.urlsafe_decode64(enc).split(":")
    { client_id: plain[0], client_secret: plain[1] }
  rescue ArgumentError => e
    nil
  end

  def client_from_body
    return nil unless params["client_id"] && params["client_secret"]

    { client_id: params["client_id"], client_secret: params["client_secret"] }
  end
end

Warden::Strategies.add(:access_token) do
  def valid?
    env['HTTP_AUTHORIZATION'] || params['access_token']
  end

  def authenticate!
    token_str = params['access_token']

    if env['HTTP_AUTHORIZATION']
      token_str = env['HTTP_AUTHORIZATION'].sub(/^Bearer/, "").strip
    end

    token = AccessToken.find(token: token_str)

    if token.nil?
      throw(:warden, message: "Access token is invalid or expired")
    else
      success!(token)
    end
  end
end