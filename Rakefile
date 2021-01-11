# frozen_string_literal: true

require_relative 'config/application'

Rails.application.load_tasks

task('default').clear # wipe the default 'spec' task created by rspec-rails
task default: ENV['CI'].present? ? %w(ci) : %w(spec:all)
