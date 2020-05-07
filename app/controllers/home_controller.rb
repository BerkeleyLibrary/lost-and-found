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
      @locations = Location.all
      @item_types = ItemType.all

      @roles = Role.all
      @roles_layout = [["Administrator","Administrator"]]
      @roles.each do |role|
        @roles_layout.push([role.role_name, role.role_name])
      end

      render :admin
    end

end