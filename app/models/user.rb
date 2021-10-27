class User < ApplicationRecord
  validates :user_name, presence: true, allow_blank: false
  validates_numericality_of :uid # TODO: fix model to use string UIDs
  attribute :user_active, :boolean, default: true

  scope :active, -> { where("user_active = true") }

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

end
