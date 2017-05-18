require 'sidekiq/web'

app_env  = ENV["APP_ENV"]
redis_url = ENV.fetch("REDIS_URL", "redis://127.0.0.1:6379")

redis_settings = {
  namespace: "sinatraapi_#{app_env}_sidekiq",
  url: redis_url,
  network_timeout: 3
}

Sidekiq.configure_server do |config|
  config.redis = redis_settings
end

Sidekiq.configure_client do |config|
  config.redis = redis_settings
end

# Password protect sidekiq web
if app_env != "development"
  Sidekiq::Web.use(Rack::Auth::Basic) do |user, password|
    [user, password] == ["admin", "example"]
  end
end
