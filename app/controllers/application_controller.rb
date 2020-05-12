# Base class for all controllers
class ApplicationController < ActionController::Base
  include ExceptionHandling
  skip_before_action :verify_authenticity_token

  def after_sign_out_path_for(resource_or_scope)
    "https://auth#{'-test' unless Rails.env.production?}.berkeley.edu/cas/logout"
  end

  helper_method :current_user?

  protected

  def current_user?
    if cookie[:uid].nil?
      false
    else
      true
    end
  end

  def authorize
    unless current_user?
      flash[:error] = "Please Login to access this page !";
      redirect_to root_url
      false
    end
  end

  def log_error(error)
    msg = {
      error: error.inspect.to_s,
      cause: error.cause.inspect.to_s
    }
    msg[:backtrace] = error.backtrace if Rails.logger.level < Logger::INFO
    logger.error(msg)
  end

  def redirect_with_params(opts = {})
    redirect_to request.parameters.update(opts)
  end

  # @param [User]
  # @return [void]
  def sign_in(user)
    cookies[:user] = user
    cookies[:user_name] = user.user_name
    cookies[:uid] = user.uid
    cookies[:user_role] = user.user_role


    logger.debug("Signed in user #{cookies[:user_name]}")
    logger.debug("Role of #{cookies[:user_role]}")
  end

  # @return [void]
  def sign_out
    reset_session
  end

def user_level_admin?
  cookies[:user_role] == "Administrator"
end

def user_level_staff?
  cookies[:user_role] == "staff" || cookies[:user_role] == "Administrator"
end

def user_level_read_only?
  cookies[:user_role] == "read-only" || cookies[:user_role] == "staff" || cookies[:user_role] == "Administrator"
end


  def user_for_paper_trail
    current_user.try!(:audit_identifier)
  end

  def calnet_uid
    session[:calnet_uid]
  end

  def user_is_registered?
    current_user.present?
  end

  def logged_in?
    calnet_uid.present?
  end

  helper_method :current_user
  helper_method :logged_in?
  helper_method :user_level_admin?
  helper_method :user_level_staff?
  helper_method :user_level_read_only?
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
