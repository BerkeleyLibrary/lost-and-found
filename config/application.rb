# Read Docker secrets into the environment. Must be before 'rails/all'.
require_relative '../lib/docker'
Docker::Secret.setup_environment!

require_relative 'boot'
require 'rails/all'

# TODO: figure out why Bundler.require() doesn't pick this up
require 'berkeley_library/logging/railtie'

Bundler.require(*Rails.groups)

module LostAndFound
  class Application < Rails::Application
    config.load_defaults 6.0

    # Set time zone
    config.time_zone = 'America/Los_Angeles'

    # Load L&F config
    config.lost_and_found = config_for(:lost_and_found)

    config.support_email = config.lost_and_found['support_email']
  end
end
