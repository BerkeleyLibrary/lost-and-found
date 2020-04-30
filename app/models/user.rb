class User < ActiveRecord::Base
  include ActiveModel::Model

  has_secure_password
  has_many :assignments
  has_many :roles, through: :assignments
  class << self

    # Returns a new user object from the given "omniauth.auth" hash. That's a
    # hash of all data returned by the auth provider (in our case, calnet).
    #
    # @see https://github.com/omniauth/omniauth/wiki/Auth-Hash-Schema OmniAuth Schema
    # @see https://git.lib.berkeley.edu/lap/altmedia/issues/16#note_5549 Sample Calnet Response
    # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    def from_omniauth(auth)
      raise Error::InvalidAuthProviderError, auth['provider'] \
        if auth['provider'].to_sym != :calnet

      new(
        display_name: auth['extra']['displayName'],
        uid: auth['extra']['uid'] || auth['uid']
      )
    end
  end

  # @return [String]
  attr_accessor :display_name

  # @return [String]
  attr_accessor :uid

  # @return [String]
  attr_accessor :role

  def authenticated?
    !uid.nil?
  end


end
