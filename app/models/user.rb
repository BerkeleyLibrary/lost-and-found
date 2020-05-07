class User < ApplicationRecord
    include ActiveModel::Model
    has_one :role

    class << self

      def from_omniauth(auth)
        raise Error::InvalidAuthProviderError, auth['provider'] \
          if auth['provider'].to_sym != :calnet

        User.where(["uid = ?", auth['uid']]).first || User.new
      end
    end
    # @return [String]
    attr_accessor :display_name
    # @return [String]
    attr_accessor :calnet_id

        # @return [String]
    attr_accessor :role
    def authenticated?
      !uid.nil?
    end
  end