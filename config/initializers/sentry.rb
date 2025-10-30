Sentry.init do |config|
  config.dsn = Rails.application.credentials.dig(:sentry, :dsn_key)

  # get breadcrumbs from logs
  config.breadcrumbs_logger = [ :active_support_logger, :http_logger ]
  # don't send default PII (personally identifiable information)
  config.send_default_pii = false
end
