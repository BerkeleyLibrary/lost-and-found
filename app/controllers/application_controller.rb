# Base class for all controllers
class ApplicationController < ActionController::Base
  include ExceptionHandling
  class_attribute :support_email, default: Rails.application.config.support_email
  helper_method :support_email

  class_attribute :timeout_message, default: 'Your session has expired. Please logout and sign in again to continue use.'
  helper_method :timeout_message

  skip_before_action :verify_authenticity_token
  before_action :check_timeout
  before_action :check_calnet
  before_action :set_paper_trail_whodunnit # mixed in by paper_trail gem
  after_action -> { flash.discard }, if: -> { request.xhr? }

  def current_user
    # TODO: something more robust, cf. Framework & UCBEARS
    session[:user]
  end

  def user_for_paper_trail
    # TODO: something more robust, cf. Framework & UCBEARS
    current_user && current_user['user_name']
  end

  def check_timeout
    if session_expired?
      reset_session
      session[:timed_out] = true
      flash[:notice] = timeout_message
      redirect_to "/logout"
    end
  end

  def session_expired?
    session[:expires_at].present? && DateTime.parse(session[:expires_at]) < DateTime.now
  end

  def check_calnet
    unless cookies[:_lost_and_found_session]
      reset_session
      session[:timed_out] = true
      flash[:notice] = timeout_message
    end
  end

  def sign_in(user)
    if user.user_active
      # TODO: don't put so much of this in the session
      session[:user] = user
      session[:user_name] = user.user_name
      session[:uid] = user.uid
      session[:user_role] = user.user_role
      session[:expires_at] = 3600.seconds.from_now
      logger.debug("Signed in user #{session[:user_name]}")
      logger.debug("Role of #{session[:user_role]}")
    elsif session[:user] == user
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

  def location_setup(initial_values = [%w[None none]])
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
