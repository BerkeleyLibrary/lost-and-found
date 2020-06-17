class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
    include ActiveModel::Model
    validates :user_name, presence: true, allow_blank: false
    validates_numericality_of :uid
    has_one :role
    attribute :user_active, :boolean, default: true

    scope :active, -> { where("user_active = true")}

    def self.find_version_author(version)
      user = "unknown"
      begin 
        user = find(version.terminator)
      rescue
        user = nil
      end
      user
    end

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