class SignedCookieGenerator
  attr_accessor :name, :value

  def initialize(name, value)
    @name = name.to_sym
    @value = value
    @cookie_jar = ActionDispatch::Cookies::CookieJar.new(
      ActiveSupport::KeyGenerator.new(
        Rails.application.secrets.secret_key_base
      ),
      Capybara.default_host,
      false,
      signed_cookie_salt: Rails.configuration.action_dispatch.encrypted_signed_cookie_salt
    )
  end

  def to_s
    "#{name}=#{signed_cookie_value};"
  end

  def signed_cookie_value
    @cookie_jar.signed[name] = { value: value }
    Rack::Utils.escape(@cookie_jar[name])
  end
end
