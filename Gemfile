# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '~> 3.3.6'

gem 'activerecord-import'
gem 'berkeley_library-docker', '~> 0.2.0'
gem 'berkeley_library-logging', '~> 0.2', '>= 0.2.5'
gem 'bootsnap', '>= 1.4.2', require: false
gem 'bootstrap'
gem 'kaminari'
gem 'lograge', '>=0.11.2'
gem 'omniauth-cas',
    git: 'https://github.com/dlindahl/omniauth-cas.git',
    ref: '7087bda829e14c0f7cab2aece5045ad7015669b1'
gem 'paper_trail', '~> 16.0'
gem 'pg'
gem 'pg_search'
gem 'puma', '~> 4.1', '>=4.3.9'
gem 'rails', '~> 8.0.2'
gem 'sass-rails', '~> 6.0'
gem 'typesafe_enum'
gem 'webpacker', '~> 5.4'

group :development, :test do
  gem 'brakeman', '~> 4.8'
  gem 'bundler-audit'
  gem 'colorize'
  gem 'factory_bot_rails'
  gem 'rspec-rails', '~> 6.1.0'
end

group :development do
  gem 'rubocop', '~> 1.60'
  gem 'rubocop-rails'
  gem 'rubocop-rspec'
end

group :test do
  gem 'capybara', '~> 3.36'
  gem 'database_cleaner-active_record', '~> 2.1'
  gem 'rspec', '~> 3.10'
  gem 'rspec_junit_formatter', '~> 0.4.1'
  gem 'selenium-webdriver', '~> 4.27'
  gem 'simplecov', require: false
  gem 'simplecov-rcov', require: false
  gem 'webmock'
end
