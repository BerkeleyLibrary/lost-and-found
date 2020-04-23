# frozen_string_literal: true

require_relative 'config/application'

Rails.application.load_tasks

desc "Default task runs the entire test suite"
task :default => [:spec] do
  system 'brakeman'
  system 'bundle-audit update'
  system 'bundle-audit check --ignore CVE-2015-9284'
end
