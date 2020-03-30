# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '~> 2.5'

gem 'rails', '~> 6.0.2', '>= 6.0.2.1'
gem 'puma', '~> 4.1'
gem 'sass-rails', '>= 6'
gem 'authlogic'
gem 'coffee-rails', '~> 4.2'
gem 'webpacker', '~> 4.0'
gem 'turbolinks', '~> 5'
gem 'jbuilder', '~> 2.7'
gem 'bootstrap'
gem 'jquery-rails'
gem 'sqlite3'
gem 'activerecord-import'
gem 'typesafe_enum'

gem 'bootsnap', '>= 1.4.2', require: false
gem 'ougai', '>=1.8.2'
gem 'lograge', '>=0.11.2'
gem 'mysql2'
gem 'omniauth'
gem 'omniauth-cas',
    git: 'https://github.com/dlindahl/omniauth-cas.git',
    ref: '7087bda829e14c0f7cab2aece5045ad7015669b1'

group :development, :test do
  gem 'rspec-rails'
  gem 'colorize'
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
end

group :development do
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :test do
  gem 'webmock'
  gem 'capybara', '>= 2.15'
  gem 'selenium-webdriver'
  gem 'webdrivers'
end

