class HomeController < ApplicationController
    def index
      render :index
    end

    def health
      check = Health::Check.new
      render json: check, status: check.http_status_code
    end

def admin_users
  @users = User.all
  @actived_users = @users.select  { |user| user.user_active}
  @deactivated_users =  @users.select  { |user| !user.user_active}

  @roles = Role.all
  @roles_layout = [["Administrator","Administrator"]]
  @roles.each do |role|
    @roles_layout.push([role.role_name, role.role_name])
  end

  render :admin_users
end

def admin_locations
  @locations = Location.all
  @actived_locations = @locations.select  { |location| location.location_active}
  @deactivated_locations =  @locations.select  { |location| !location.location_active}

  render :admin_locations
end

def admin_item_types
  @item_types = ItemType.all
  @actived_item_types = @item_types.select  { |item_type| item_type.type_active}
  @deactivated_item_types =  @item_types.select  { |item_type| !item_type.type_active}

  render :admin_item_types
end

    def admin_items
      @items = Item.all
      @items_found = Item.found
      @items_claimed = Item.claimed

      render :admin_items
    end

    def admin_roles
      render :admin_roles
    end

    def admin
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