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
    config.load_defaults 8.0

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # This is required for PaperTrail >= 13, which uses safe YAML loading.
    config.after_initialize do
      ActiveRecord.yaml_column_permitted_classes += [
        Date, BigDecimal, ActiveSupport::TimeWithZone, Time, ActiveSupport::TimeZone
      ]
    end

    # Set time zone
    config.time_zone = 'America/Los_Angeles'

    # Load L&F config
    config.lost_and_found = config_for(:lost_and_found)

    config.support_email = config.lost_and_found['support_email']
  end
end
