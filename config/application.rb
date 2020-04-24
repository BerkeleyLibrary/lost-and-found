require_relative '../lib/docker'
Docker::Secret.setup_environment!

require_relative 'boot'
require 'rails/all'
Bundler.require(*Rails.groups)
require_relative '../app/loggers/lost_and_found_logger'

Bundler.require(*Rails.groups)
module LostAndFound
  class Application < Rails::Application
    config.load_defaults 6.0
    config.action_view.field_error_proc = proc { |tag, _instance| tag }
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

    Rails.application.config.middleware.use OmniAuth::Builder do
      provider :cas, host: 'localhost'
    end
  end
end
