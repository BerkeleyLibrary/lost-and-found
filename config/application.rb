require_relative '../lib/docker'
Docker::Secret.setup_environment!
require_relative 'boot'
require 'rails/all'
Bundler.require(*Rails.groups)
require_relative '../app/loggers/lost_and_found_logger'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module LostAndFound
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0
    config.lograge.enabled = true
    config.logger = LostAndFoundLogger::Logger.new($stdout)
    config.lograge.custom_options = ->(event) do
      {
        time: Time.now,
        request_id: event.payload[:headers].env['action_dispatch.request_id'],
        remote_ip: event.payload[:headers][:REMOTE_ADDR]
      }
    end
    config.lograge.formatter = Class.new do |fmt|
      def fmt.call(data)
        { msg: 'Request', request: data }
      end
    end

  end
end
