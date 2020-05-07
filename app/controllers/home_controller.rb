class HomeController < ApplicationController
    def index
      render :index
    end

    def health
      check = Health::Check.new
      render json: check, status: check.http_status_code
    end

    def admin
      @users = User.all
      render :admin
    end

end