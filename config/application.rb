# Dummy SECRET_KEY_BASE to prevent spurious initializer issues
# -- see https://github.com/rails/rails/issues/32947
ENV['SECRET_KEY_BASE'] ||= '1' if ENV['CI']

require_relative 'boot'

require 'rails'
require 'active_model/railtie'
require 'active_record/railtie'
require 'active_storage/engine'
require 'action_controller/railtie'
require 'action_view/railtie'
require 'sprockets/railtie'

# TODO: figure out why Bundler.require() doesn't pick this up
require 'berkeley_library/logging/railtie'

Bundler.require(*Rails.groups)

module LostAndFound
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0

    # Defaults from 6.1, to avoid deprecation warnings in 7.0+:
    config.action_dispatch.cookies_same_site_protection = :strict
    config.action_controller.urlsafe_csrf_tokens = true
    config.active_record.legacy_connection_handling = false

    # Set time zone
    config.time_zone = 'America/Los_Angeles'

    # Load L&F config
    config.lost_and_found = config_for(:lost_and_found)

    config.support_email = config.lost_and_found['support_email']
  end
end
