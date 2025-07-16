# frozen_string_literal: true

ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __dir__)

require 'logger'  # Work-around for Rails 7.0 bug; remove when upgraded to 7.1
require 'bundler/setup'
