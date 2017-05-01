class BaseSerializer
  include JSONAPI::Serializer

  def base_url
    ENV.fetch("API_BASE_URL", "https://example.com") + "/v1"
  end
end
