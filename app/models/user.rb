class User
  include ActiveModel::Model

  LOSTANDFOUND_ADMIN_GROUP = 'cn=edu:berkeley:org:libr:framework:LIBR-lostandfound-admins,ou=campus groups,dc=berkeley,dc=edu'.freeze

  class << self
    def from_omniauth(auth)
      raise Error::InvalidAuthProviderError, auth['provider'] \
        if auth['provider'].to_sym != :calnet

      new(
        display_name: auth['extra']['displayName'],
        email: auth['extra']['berkeleyEduOfficialEmail'],
        employee_id: auth['extra']['employee_id'],
        uid: auth['extra']['uid'] || auth['uid'],
        lostandfound_admin: auth['extra']['berkeleyEduIsMemberOf'].include?(LOSTANDFOUND_ADMIN_GROUP)
      )
    end
  end

  # @return [String]
  attr_accessor :display_name

  # @return [String]
  attr_accessor :email

  # @return [String]
  attr_accessor :employee_id

  # @return [String]
  attr_accessor :uid

  # @return [Boolean]
  attr_accessor :lostandfound_admin

  def authenticated?
    !uid.nil?
  end
end
