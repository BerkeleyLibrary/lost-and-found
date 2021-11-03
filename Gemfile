# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '~> 2.6'

gem 'activerecord-import'
gem 'authlogic'
gem 'bcrypt', '~> 3.1', '>= 3.1.11'
gem 'berkeley_library-logging', '~> 0.2', '>= 0.2.4'
gem 'bootsnap', '>= 1.4.2', require: false
gem 'bootstrap'
gem 'coffee-rails', '~> 4.2'
gem 'diffy'
gem 'jbuilder', '~> 2.5'
gem 'jquery-rails'
gem 'kaminari'
gem 'lograge', '>=0.11.2'
gem 'omniauth-cas',
    git: 'https://github.com/dlindahl/omniauth-cas.git',
    ref: '7087bda829e14c0f7cab2aece5045ad7015669b1'
gem 'paper_trail'
gem 'pg'
gem 'pg_search'
gem 'puma', '~> 4.1', '>=4.3.9'
gem 'pundit'
gem 'rails', '>= 6.1'
gem 'sass-rails', '~> 6.0'
gem 'typesafe_enum'
gem 'webpacker', '~> 5.4'

group :development, :test do
  gem 'brakeman', '~> 4.8'
  gem 'bundler-audit'
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'colorize'
  gem 'factory_bot_rails'
  gem 'rspec-rails'
end

group :development do
  gem 'listen'
  gem 'rubocop', '~> 1.18.0'
  gem 'rubocop-rails'
  gem 'rubocop-rspec'
  gem 'web-console', '>= 3.3.0'
end

group :test do
  gem 'capybara', '~> 3.36'
  gem 'database_cleaner-active_record', '~> 2.0'
  gem 'rspec', '~> 3.10'
  gem 'rspec_junit_formatter', '~> 0.4.1'
  gem 'selenium-webdriver', '~> 4.0'
  gem 'simplecov', require: false
  gem 'simplecov-rcov', require: false
  gem 'webmock'
end
