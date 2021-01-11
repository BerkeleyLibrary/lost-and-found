Rails.application.configure do
  config.cache_classes = false
  config.eager_load = false
  config.public_file_server.enabled = true
  config.public_file_server.headers = {
    'Cache-Control' => "public, max-age=#{1.hour.to_i}"
  }

  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false
  config.cache_store = :null_store

  config.action_dispatch.show_exceptions = false
  config.action_controller.allow_forgery_protection = false
  config.active_storage.service = :test
  config.action_mailer.perform_caching = false
  config.action_mailer.delivery_method = :test
  config.active_support.deprecation = :log
  config.assets.debug = true
  config.assets.quiet = true
  config.lograge.enabled = true
  config.middleware.use RackSessionAccess::Middleware
  # Short circuits test flow.
  # See documentation here: https://github.com/omniauth/omniauth/wiki/Integration-Testing
  OmniAuth.config.test_mode = true
  config.logger = LostAndFoundLogger::Logger.new(config.root.join('log/test.log'))
end
