# ------------------------------------------------------------
# Rails

ENV['RAILS_ENV'] ||= 'test'

# ------------------------------------------------------------
# Dependencies

require 'spec_helper'

require File.expand_path('../config/environment', __dir__)
require 'rspec/rails'
require 'paper_trail/frameworks/rspec'

# ------------------------------------------------------------
# RSpec configuration

RSpec.configure do |config|
  config.use_transactional_fixtures = false

  config.before(:suite) do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.clean_with(:truncation)
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end
end

# ------------------------------------------------------------
# FactoryBot

require 'support/factory_bot'

# ------------------------------------------------------------
# Calnet

module CalnetHelper
  IDS = {
    admin: '5551215'.freeze,
    staff: '5551214'.freeze,
    read_only: '5551212'.freeze,
    other: '5551213'.freeze
  }.freeze

  ROLES = {
    admin: 'Administrator',
    staff: 'Staff',
    read_only: 'Read-only'
  }.freeze

  def mock_login(type)
    role = ROLES[type]
    auth_hash = mock_auth_hash(type)
    ensure_user!(role, auth_hash) if role

    mock_omniauth_login(auth_hash)
  end

  def mock_user_without_login(type)
    auth_hash = mock_auth_hash(type)
    User.from_omniauth(auth_hash)
  end

  def mock_omniauth_login(auth_hash)
    last_signed_in_user = nil

    # We want the actual user object from the session, but system specs don't provide
    # access to it, so we intercept it at sign-in
    allow_any_instance_of(SessionsController).to receive(:sign_in).and_wrap_original do |m, *args|
      last_signed_in_user = args[0]
      m.call(*args)
    end
    log_in_with_omniauth(auth_hash)

    last_signed_in_user
  end

  def mock_auth_hash(type)
    raise ArgumentError, "Unknown user type: #{type.inspect}" unless (id = uid_for(type))

    auth_hash_for(id)
  end

  def uid_for(type)
    IDS[type]
  end

  def auth_hash_for(uid)
    calnet_yml_file = "spec/data/calnet/#{uid}.yml"
    raise IOError, "No such file: #{calnet_yml_file}" unless File.file?(calnet_yml_file)

    YAML.load_file(calnet_yml_file)
  end

  # Logs out. Suitable for calling in an after() block.
  def logout!
    unless respond_to?(:page)
      # Selenium doesn't know anything about webmock and will just hit the real logout path
      stub_request(:get, 'https://auth-test.berkeley.edu/cas/logout').to_return(status: 200)
      without_redirects { do_get logout_path }
    end

    # ActionDispatch::TestProcess#session delegates to request.session,
    # but doesn't check whether it's actually present
    request.reset_session if request

    OmniAuth.config.mock_auth[:calnet] = nil
    CapybaraHelper.delete_all_cookies if defined?(CapybaraHelper)
  end

  # Gets the specified URL, either via the driven browser (in a system spec)
  # or directly (in a request spec)
  def do_get(path)
    return visit(path) if respond_to?(:visit)

    get(path)
  end

  # Capybara Rack::Test mock browser is notoriously stupid about external redirects
  # https://github.com/teamcapybara/capybara/issues/1388
  def without_redirects
    return yield unless can_disable_redirects?

    page.driver.follow_redirects?.tap do |was_enabled|
      page.driver.options[:follow_redirects] = false
      yield
    ensure
      page.driver.options[:follow_redirects] = was_enabled
    end
  end

  def ensure_all_users!
    IDS.each do |type, uid|
      role = ROLES[type]
      auth_hash = auth_hash_for(uid)
      ensure_user!(role, auth_hash)
    end
  end

  private

  def ensure_user!(role, auth_hash)
    uid = auth_hash['uid'].to_i # TODO: fix model to use string UIDs

    unless (user = User.find_by(uid: uid))
      return User.create(
        uid: uid,
        user_name: auth_hash['extra']['displayName'],
        user_role: role,
        updated_by: 'Test',
        user_active: true
      )
    end

    user.tap do |u|
      u.update!(user_role: role, user_active: true) unless u.user_role == role && u.user_active?
    end
  end

  def log_in_with_omniauth(auth_hash)
    OmniAuth.config.mock_auth[:calnet] = auth_hash
    do_get login_path

    Rails.application.env_config['omniauth.auth'] = auth_hash
    do_get omniauth_callback_path(:calnet)
  end

  def can_disable_redirects?
    respond_to?(:page) && page.driver.respond_to?(:follow_redirects?)
  end
end

RSpec.configure do |config|
  config.include(CalnetHelper)
end
