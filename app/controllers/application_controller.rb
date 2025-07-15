# Base class for all controllers
class ApplicationController < ActionController::Base
  include ExceptionHandling

  # ------------------------------------------------------------
  # Global controller configuration

  # @see https://api.rubyonrails.org/classes/ActionController/RequestForgeryProtection/ClassMethods.html
  protect_from_forgery with: :exception, prepend: true

  # ------------------------------
  # Email helpers

  SUPPORT_EMAIL_STAFF = 'helpbox@library.berkeley.edu'.freeze

  attr_writer :support_email

  def support_email
    @support_email || support_email_default
  end
  helper_method :support_email

  def support_email_default
    Rails.application.config.support_email || SUPPORT_EMAIL_STAFF
  end

  # ------------------------------------------------------------
  # Public methods

  # ------------------------------
  # Authentication/Authorization

  # Require that the current user be authenticated
  #
  # @return [void]
  # @raise [Error::UnauthorizedError] If the user is not
  #   authenticated
  def authenticate!
    raise Error::UnauthorizedError, "Endpoint #{controller_name}/#{action_name} requires authentication" unless authenticated?

    yield current_user if block_given?
  end

  # Return whether the current user is authenticated
  #
  # @return [Boolean]
  def authenticated?
    current_user.authenticated?
  end

  # Return the current user
  #
  # This always returns a user object, even if the user isn't authenticated.
  # Call {User#authenticated?} to determine if they were actually auth'd, or
  # use the shortcut {#authenticated?} to see if the current user is auth'd.
  #
  # @return [User]
  def current_user
    @current_user ||= User.from_session(session)
  end
  helper_method :current_user

  # Sign in the user by storing their data in the session
  #
  # @param [User]
  # @return [void]
  def sign_in(user)
    # TODO: connect session to DB users in less hacky way
    session[:user] = user
    session[:expires_at] = 3600.seconds.from_now
  end

  # Sign out the current user by clearing all session data
  #
  # @return [void]
  def sign_out
    reset_session
  end

  def require_authorization!
    authenticate!
    return if current_user.authorized?

    raise Error::ForbiddenError, 'This page is restricted to authorized users.'
  end

  def require_staff_or_admin!
    authenticate!
    return if current_user.staff_or_admin?

    raise Error::ForbiddenError, 'This page is restricted to authorized staff and administrative users.'
  end

  def require_admin!
    authenticate!
    return if current_user.administrator?

    raise Error::ForbiddenError, 'This page is restricted to administrative users.'
  end

  # ------------------------------
  # Session expiration

  def logout_if_expired!
    return unless session_expired?

    redirect_to logout_path
  end

  def session_expired?
    return false unless (expires_at = session_expiration_time)

    (Time.current > expires_at).tap do |expired|
      logger.warn("Expiration time #{expires_at} reached; session expired") if expired
    end
  end

  def session_expiration_time
    session[:expires_at]
  end

  # ------------------------------
  # Form helpers

  def location_setup
    # TODO: enforce case-insensitive uniqueness w/o mangling user-entered names
    location_names = Location.order(:location_name).pluck(:location_name)
    location_names.map { |n| [n.titleize, n] }
  end

  # TODO: simplify this
  def item_type_setup
    # TODO: enforce case-insensitive uniqueness w/o mangling user-entered names
    type_names = ItemType.editable.order(:type_name).pluck(:type_name)
    type_names.unshift('other')
    type_names.map { |n| [n.titleize, n] }
  end

  # ------------------------------
  # Flash alerts

  def flash_errors(model, exception = nil, now: false)
    msg = error_messages_from(model) || exception || 'An unexpected error occurred'

    add_flash(now ? flash.now : flash, :alert, msg)
  end

  # ------------------------------------------------------------
  # Private methods

  private

  def error_messages_from(model)
    return unless model
    return unless (errors = model.errors)
    return unless (full_messages = errors.full_messages)
    return if full_messages.empty?

    full_messages
  end

  def add_flash(flash_obj, lvl, msg)
    flash_array = ensure_flash_array(flash_obj, lvl)
    msg.is_a?(Array) ? flash_array.concat(msg) : flash_array << msg
  end

  def ensure_flash_array(flash_obj, lvl)
    current = (flash_obj[lvl] ||= [])
    current.is_a?(Array) ? current : (flash_obj[lvl] = Array(current))
  end
end
