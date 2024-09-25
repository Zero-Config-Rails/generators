Sentry.init do |config|
  config.dsn = Rails.application.credentials.dig(:sentry, :dsn_key)
  # enable performance monitoring
  config.enable_tracing = true
  # get breadcrumbs from logs
  config.breadcrumbs_logger = [ :active_support_logger, :http_logger ]
end
