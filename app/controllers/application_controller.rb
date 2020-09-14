# Base class for all controllers
class ApplicationController < ActionController::Base
  include ExceptionHandling
  class_attribute :support_email, default: 'bescamilla@berkeley.edu'
  helper_method :support_email

  skip_before_action :verify_authenticity_token
  before_action :check_timeout
  before_action :check_calnet
  before_action :set_paper_trail_whodunnit
  after_action -> { flash.discard }, if: -> { request.xhr? }

  def check_timeout
    if session[:expires_at].present? && DateTime.parse(session[:expires_at]) < DateTime.now
      reset_session
      session[:timed_out] = "Timed Out"
      flash[:notice] = 'Your session has expired. Please logout and sign in again to continue use.'
    end
  end

  def check_calnet
    unless cookies[:_lost_and_found_session]
      reset_session
      session[:timed_out] = "Timed Out"
      flash[:notice] = 'Your session has expired. Please logout and sign in again to continue use.'
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

  def sign_in(user)
    if user.user_active
      session[:user] = user
      session[:user_name] = user.user_name
      session[:uid] = user.uid
      session[:user_role] = user.user_role
      session[:expires_at] = 60.minutes.from_now

      logger.debug("Signed in user #{session[:user_name]}")
      logger.debug("Role of #{session[:user_role]}")
    elsif
      session[:user] = user
      session[:user_role] = 'deactivated'
    end
  end

  def sign_out
    cookies.clear
    reset_session
  end

  def user_present?
    session[:user].present?
  end

  def user_level_admin?(suppress_alert = false)
    if session[:user_role] != 'Administrator'
      flash.now.alert = 'You must have Admin level permission to view this page' unless suppress_alert || !session[:user]
      check_timeout
      return false
    end
    true
  end

  def user_level_staff?(suppress_alert = false)
    if session[:user_role] != 'Staff' && session[:user_role] != 'Administrator'
      flash.now.alert = 'You must have staff level permission or greater to view this page' unless suppress_alert || !session[:user]
      check_timeout
      return false
    end
    true
  end

  def user_level_read_only?(suppress_alert = false)
    if session[:user_role] != 'Read-only' && session[:user_role] != 'Staff' && session[:user_role] != 'Administrator'
      flash.now.alert = 'You must be a registered user to view this page' unless suppress_alert || !session[:user]
      check_timeout
      return false
    end
    true
  end

  helper_method :user_level_admin?
  helper_method :user_level_staff?
  helper_method :user_level_read_only?

  def location_setup( initial_values = [%w[None none]])
    locations = Location.active
    locations.map { |location| location.location_name.downcase! }
    locations = locations.sort_by(&:location_name)
    locations_layout = initial_values
    locations.each do |location|
      locations_layout.push([location.location_name.titleize, location.location_name])
    end
    locations_layout
  end

  def item_type_setup(initial_values = [%w[None none]])
    item_types = ItemType.active
    item_types.map { |itemType| itemType.type_name.downcase! }
    item_types = item_types.sort_by(&:type_name)
    item_type_layout = initial_values
    item_types.each do |type|
      item_type_layout.push([type.type_name.titleize, type.type_name])
    end
    item_type_layout
  end

end
