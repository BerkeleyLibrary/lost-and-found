# frozen_string_literal: true

class SessionsController < ApplicationController
  skip_before_action :ensure_authenticated_user
  skip_before_action :check_timeout

  def new
    if session[:user]
      redirect_to '/home'
    else
      redirect_to '/auth/calnet'
    end
  end

  def callback
    logger.debug(
      msg: 'Received omniauth callback',
      omniauth: auth_params
    )

    @user = User.from_omniauth(auth_params)

    sign_in @user
    redirect_to request.env['omniauth.origin'] || home_path
  end

  def destroy
    sign_out
    end_url = "https://auth#{'-test' unless Rails.env.production?}.berkeley.edu/cas/logout"
    redirect_to end_url
  end

  def failure
    check = Health::Check.new
    render json: check, status: check.http_status_code
  end

  def create
    logger.debug({
                   msg: 'Received omniauth callback',
                   omniauth: auth_params
                 })

    @user = User.from_omniauth(auth_hash)

    redirect_to request.env['omniauth.origin'] || home_path
  end

  protected

  def auth_hash
    request.env['omniauth.auth']
  end

  private

  def auth_params
    request.env['omniauth.auth']
  end

  def cas_host
    Rails.application.config.omniauth.fetch(:cas_host)
  end
end
