class HomeController < ApplicationController

    self.support_email = 'webman@library.berkeley.edu'

    def index
      render :index
    end
    def health
      check = Health::Check.new
      render json: check, status: check.http_status_code
    end

    def admin
      authenticate!
      raise Error::ForbiddenError, "Endpoint #{controller_name}/#{action_name} requires user be an admin " unless current_user.role=='admin'
      render :admin
    end
  end