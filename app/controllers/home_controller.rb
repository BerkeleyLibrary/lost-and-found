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
      @actived_users = @users.select  { |user| user.user_active}
      @deactivated_users =  @users.select  { |user| !user.user_active}

      @locations = Location.all
      @actived_locations = @locations.select  { |location| location.location_active}
      @deactivated_locations =  @locations.select  { |location| !location.location_active}

      @item_types = ItemType.all
      @actived_item_types = @item_types.select  { |item_type| item_type.type_active}
      @deactivated_item_types =  @item_types.select  { |item_type| !item_type.type_active}

      @roles = Role.all
      @roles_layout = [["Administrator","Administrator"]]
      @roles.each do |role|
        @roles_layout.push([role.role_name, role.role_name])
      end

      render :admin
    end

end