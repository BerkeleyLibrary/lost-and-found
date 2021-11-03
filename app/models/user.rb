class User < ApplicationRecord

  ROLE_ADMIN = 'Administrator'.freeze
  ROLE_STAFF = 'Staff'.freeze
  ROLE_READ_ONLY = 'Read-only'.freeze
  ROLES = [ROLE_ADMIN, ROLE_STAFF, ROLE_READ_ONLY].freeze

  validates :user_name, presence: true, allow_blank: false
  validates :uid, presence: true, numericality: true
  validates :user_role, inclusion: ROLES

  scope :active, -> { where(user_active: true) } # TODO: just rename the columns
  scope :inactive, -> { where(user_active: false) }

  class << self
    def from_omniauth(auth)
      ensure_valid_provider(auth['provider'])

      uid = ensure_valid_uid(auth['uid'])
      existing_user = log_in_as(uid)
      return existing_user if existing_user

      User.new(
        uid: uid,
        user_name: auth['extra']['displayName'],
        user_active: false
      )
    end

    def from_session(session)
      attrs = OpenStruct.new((session && session[:user]) || {})
      # TODO: connect session to DB users in less hacky way

      session_uid = attrs.uid
      existing_user = log_in_as(session_uid)
      return existing_user if existing_user

      User.new(
        uid: session_uid,
        user_name: attrs.user_name,
        user_active: false
      )
    end

    private

    def log_in_as(uid)
      uid && User.find_by(uid: uid)
    end

    def ensure_valid_uid(uid_str)
      uid_str.to_i.tap do |uid_int|
        raise ArgumentError, "Invalid numeric UID: #{uid_str.inspect}" unless uid_int.to_s == uid_str.to_s
      end
    end

    def ensure_valid_provider(provider)
      raise Error::InvalidAuthProviderError, provider if provider.to_sym != :calnet
    end
  end

  def authenticated?
    !uid.nil?
  end

  def authorized?
    persisted? && user_active? && ROLES.include?(user_role)
  end

  def administrator?
    user_role == ROLE_ADMIN
  end

  def staff?
    user_role == ROLE_STAFF
  end

  def read_only?
    user_role == ROLE_READ_ONLY
  end

  def staff_or_admin?
    # TODO: map roles to capabilities or something
    staff? || administrator?
  end

end
