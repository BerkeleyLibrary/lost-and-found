# Base class for all controllers
class ApplicationController < ActionController::Base
  include ExceptionHandling
  skip_before_action :verify_authenticity_token


  def authenticate!
    unless authenticated?
      raise Error::UnauthorizedError, "Endpoint #{controller_name}/#{action_name} requires authentication"
    end
  end

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


  def ensure_authenticated_user
    if calnet_uid.blank?
      session[:original_url] = request.env['REQUEST_URI']
    end
  end

  def current_user
    return @current_user if @current_user
    
    @current_user = User.find_by(calnet_uid: calnet_uid) || User.new(calnet_uid: calnet_uid)
    @current_user.log_web_access
    @current_user
  end

  def user_for_paper_trail
    current_user.try!(:audit_identifier)
  end

  def calnet_uid
    session[:calnet_uid]
  end

  def user_is_admin?
    current_user.try(:admin?)
  end

  def user_is_registered?
    current_user.present?
  end

  def logged_in?
    calnet_uid.present?
  end

  helper_method :current_user
  helper_method :logged_in?
  helper_method :user_is_admin?
  helper_method :user_is_registered?

  def camelize_json(json_hash)
    json_hash.as_json.camelize_keys
  end

  def q_params(attrs)
    params[:q] ||= {}
    ignores = ["q", "controller", "action", "format", "token", "utf8", "commit"]

    params.keys.each do |key|
      params[:q][key] = params.delete(key) unless ignores.include?(key) 
    end

    (params[:q] ? params[:q].permit(attrs) : params.permit!).to_h.to_h.symbolize_keys
  end







end
