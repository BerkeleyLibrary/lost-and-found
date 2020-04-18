class User < ApplicationRecord
  include ActiveModel::Model

  belongs_to :role
  class << self

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
