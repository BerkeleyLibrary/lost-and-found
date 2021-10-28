# Base class for all controllers
class ApplicationController < ActionController::Base
  include ExceptionHandling

  # ------------------------------------------------------------
  # Global controller configuration

  # @see https://api.rubyonrails.org/classes/ActionController/RequestForgeryProtection/ClassMethods.html
  protect_from_forgery with: :exception

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
  helper_method :authenticated?

  # Return the current user
  #
  # This always returns a user object, even if the user isn't authenticated.
  # Call {User#authenticated?} to determine if they were actually auth'd, or
  # use the shortcut {#authenticated?} to see if the current user is auth'd.
  #
  # @return [User]
  def current_user
    @current_user ||= (User.from_session(session) || User.new)
  end
  helper_method :current_user

  # Sign in the user by storing their data in the session
  #
  # @param [User]
  # @return [void]
  def sign_in(user)
    # TODO: connect session to DB users in less hacky way
    session[:user] = { 'uid' => user.uid }
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
  # Version tracking

  def user_for_paper_trail
    # TODO: something more robust, cf. Framework & UCBEARS
    current_user && current_user.user_name
  end

  # ------------------------------
  # Session expiration

  def logout_if_expired!
    if session_expired?
      reset_session
      flash[:notice] = timeout_message
      redirect_to "/logout"
    end
  end

  def session_expired?
    session[:expires_at].present? && DateTime.parse(session[:expires_at]) < DateTime.now
  end

  # ------------------------------
  # Display helpers

  # TODO: use Rails i18n
  def timeout_message
    'Your session has expired. Please logout and sign in again to continue use.'
  end

  # ------------------------------
  # Form helpers

  # TODO: simplify this
  def location_setup
    location_names = Location.active.pluck(:location_name).sort
    location_names.map { |n| [n.titleize, n] }.unshift(['(any location)', nil])
  end

  # TODO: simplify this
  def item_type_setup
    type_names = ItemType.active.pluck(:type_name).sort
    type_names.map { |n| [n.titleize, n] }.unshift(['(any type)', nil])
  end

  # ------------------------------
  # Flash alerts

  def flash_errors(model, exception = nil)
    msg = error_messages_from(model) || exception || 'An unexpected error occurred'

    flash!(:alert, msg)
  end

  def flash!(lvl, msg)
    add_flash(flash, lvl, msg)
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
