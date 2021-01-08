require 'rails_helper'
require 'user_helper'

def login_as(user_id)
  mock_omniauth_login(user_id)
end

def logout!
  OmniAuth.config.mock_auth[:calnet] = nil
  stub_request(:get, 'https://auth-test.berkeley.edu/cas/logout').to_return(status: 200)
  without_redirects { do_get logout_path }
end

def with_login(user_id)
  user = login_as(user_id)
  yield user
rescue StandardError => e
  puts "#{e}\n\t#{e.backtrace.join("\n\t")}"
  raise
ensure
  logout!
end

def mock_omniauth_login(user_id)
  calnet_yml_file = "spec/data/calnet/#{user_id}.yml"
  raise IOError, "No such file: #{calnet_yml_file}" unless File.file?(calnet_yml_file)

  auth_hash = YAML.load_file(calnet_yml_file)
  OmniAuth.config.mock_auth[:calnet] = auth_hash

  Rails.application.env_config['omniauth.auth'] = auth_hash
  do_get omniauth_callback_path(:calnet)

  User.from_omniauth(auth_hash)
end

def do_get(path)
  return visit(path) if respond_to?(:visit)

  get(path)
end

def without_redirects
  if respond_to?(:page)
    was_enabled = page.driver.follow_redirects?
    begin
      page.driver.options[:follow_redirects] = false
      yield
    ensure
      page.driver.options[:follow_redirects] = was_enabled
    end
  else
    yield
  end
end
