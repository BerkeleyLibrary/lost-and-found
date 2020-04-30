# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '~> 2.6'

gem 'activerecord-import'
gem 'authlogic'
gem 'bcrypt', '~> 3.1', '>= 3.1.11'
gem 'bootsnap', '>= 1.4.2', require: false
gem 'bootstrap-sass'
gem 'coffee-rails', '~> 4.2'
gem 'jbuilder', '~> 2.7'
gem 'jquery-rails'
gem 'lograge', '>=0.11.2'
gem 'mysql2'
gem 'omniauth-cas',
    git: 'https://github.com/dlindahl/omniauth-cas.git',
    ref: '7087bda829e14c0f7cab2aece5045ad7015669b1'
gem 'ougai', '>=1.8.2'
gem 'puma', '~> 4.1'
gem 'pundit'
gem 'rails', '~> 6.0.2', '>= 6.0.2.1'
gem 'sqlite3'
gem 'turbolinks', '~> 5'
gem 'typesafe_enum'
gem 'webpacker', '~> 4.0'

group :development, :test do
  gem 'bundler-audit', '~> 0.3.0'
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'colorize'
  gem 'rspec'
  gem 'rspec-rails'
end

group :development do
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'web-console', '>= 3.3.0'
end

group :test do
  gem 'brakeman', '~> 4.8'
  gem 'capybara', '>= 2.15'
  gem 'rspec_junit_formatter', '~> 0.4.1'
  gem 'selenium-webdriver'
  gem 'webdrivers'
  gem 'webmock'
end
