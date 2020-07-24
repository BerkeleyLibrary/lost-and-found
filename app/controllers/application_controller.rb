# Base class for all controllers
class ApplicationController < ActionController::Base
  include ExceptionHandling
  class_attribute :support_email, default: 'privdesk@library.berkeley.edu'
  helper_method :support_email

  skip_before_action :verify_authenticity_token
  before_action :ensure_authenticated_user
  before_action :check_timeout
  before_action :set_paper_trail_whodunnit

  def current_user
    cookies[:user_name]
  end

  def after_sign_out_path_for(_resource_or_scope)
    "https://auth#{'-test' unless Rails.env.production?}.berkeley.edu/cas/logout"
  end

  def check_timeout
    if cookies[:expires_at].present? && DateTime.parse(cookies[:expires_at]) < DateTime.now
      sign_out
      cookies[:logout_required] = true
      flash[:notice] = 'Your session has expired. Please logout and sign in again to continue use.'
    end
  end

  helper_method :current_user?

  def ensure_authenticated_user
    if cookies[:logout_required].present?
      reset_session
      flash[:notice] = 'Your session has expired. Please logout and sign in again to continue use.'
    end
  end

  def current_user?
    if cookie[:uid].nil?
      false
    else
      true
    end
  end

  def current_user
    User.where(uid: cookies[:uid]).first
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

  def sign_in(user)
    cookies[:user] = user
    cookies[:user_name] = user.user_name
    cookies[:uid] = user.uid
    cookies[:user_role] = user.user_role
    cookies[:expires_at] = 60.minutes.from_now

    @current_user = user
    @current_user.uid = user.uid
    @current_user.user_name = user.user_name
    @current_user.user_role = user.user_role

    logger.debug("Signed in user #{cookies[:user_name]}")
    logger.debug("Role of #{cookies[:user_role]}")
  end

  def sign_out
    cookies[:user] = nil
    cookies.clear
    reset_session
  end


  def user_present?
    cookies[:user].present?
  end


  def user_level_admin?(set_alert = false)
    if cookies[:user_role] != 'Administrator'
      flash.now.alert = 'You must have Admin level permission to view this page' unless set_alert || cookies[:logout_required]
      check_timeout
      return false
    end
    true
  end

  def user_level_staff?(set_alert = false)
    if cookies[:user_role] != 'Staff' && cookies[:user_role] != 'Administrator'
      flash.now.alert = 'You must have staff level permission or greater to view this page' unless set_alert || cookies[:logout_required]
      check_timeout
      return false
    end
    true
  end

  def user_level_read_only?(set_alert = false)
    if cookies[:user_role] != 'Read-only' && cookies[:user_role] != 'Staff' && cookies[:user_role] != 'Administrator'
      flash.now.alert = 'You must be a registered user to view this page' unless set_alert || cookies[:logout_required]
      check_timeout
      return false
    end
    true
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

  def location_setup
    locations = Location.active
    locations.map { |location| location.location_name.downcase! }
    locations = locations.sort_by(&:location_name)
    locations_layout = [%w[None none]]
    locations.each do |location|
      locations_layout.push([location.location_name.titleize, location.location_name])
    end
    locations_layout
  end

  def item_type_setup
    item_types = ItemType.active
    item_types.map { |itemType| itemType.type_name.downcase! }
    item_types = item_types.sort_by(&:type_name)
    item_type_layout = [%w[None none]]
    item_types.each do |type|
      item_type_layout.push([type.type_name.titleize, type.type_name])
    end
    item_type_layout
  end

  def q_params(attrs)
    params[:q] ||= {}
    ignores = %w[q controller action format token utf8 commit]

    params.keys.each do |key|
      params[:q][key] = params.delete(key) unless ignores.include?(key)
    end

    (params[:q] ? params[:q].permit(attrs) : params.permit!).to_h.to_h.symbolize_keys
  end

end
