class HomeController < ApplicationController

    self.support_email = 'webman@library.berkeley.edu'

    def health
      check = Health::Check.new
      render json: check, status: check.http_status_code
    end

    def admin
      authenticate!
      raise Error::ForbiddenError, "Endpoint #{controller_name}/#{action_name} requires framework admin CalGroup" unless current_user.lostandfound_admin
      render :admin
    end
  end