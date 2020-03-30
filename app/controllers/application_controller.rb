# Base class for all controllers
class ApplicationController < ActionController::Base
  include ExceptionHandling

  class_attribute :support_email, default: 'privdesk@library.berkeley.edu'
  helper_method :support_email


  private

  def authenticate!
    unless authenticated?
      raise Error::UnauthorizedError, "Endpoint #{controller_name}/#{action_name} requires authentication"
      end
  end

  # Return whether the current user is authenticated
  #
  # @return [Boolean]
  def authenticated?
    current_user.authenticated?
  end
  helper_method :authenticated?

  def current_user
    @current_user ||= User.new(session[:user] || {})
  end

  def log_error(error)
    msg = {
      error: error.inspect.to_s,
      cause: error.cause.inspect.to_s
    }
    msg[:backtrace] = error.backtrace if Rails.logger.level < Logger::INFO
    logger.error(msg)
  end

  # Perform a redirect but keep all existing request parameters
  #
  # This is a workaround for not being able to redirect a POST/PUT request.
  def redirect_with_params(opts = {})
    redirect_to request.parameters.update(opts)
  end

  # Sign in the user by storing their data in the session
  #
  # @param [User]
  # @return [void]
  def sign_in(user)
    session[:user] = user
    logger.debug("Signed in user #{session[:user]}")
  end

  # Sign out the current user by clearing all session data
  #
  # @return [void]
  def sign_out
    reset_session
  end
end
