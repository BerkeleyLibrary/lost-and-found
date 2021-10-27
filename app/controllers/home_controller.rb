class HomeController < ApplicationController
  before_action(:logout_if_expired!, except: :health)
  before_action(:require_admin!, except: :health)

  def health
    check = Health::Check.new
    render json: check, status: check.http_status_code
  end

  def admin_users
    @users = User.all
    @actived_users = @users.select(&:user_active)
    @deactivated_users = @users.reject(&:user_active)
    render :admin_users
  end

  def admin_locations
    @locations = Location.all
    @actived_locations = @locations.select(&:location_active)
    @actived_locations.each { |location| location.location_name.downcase! }
    @actived_locations.sort_by!(&:location_name)

    @deactivated_locations = @locations.reject(&:location_active)
    @deactivated_locations.each { |location| location.location_name.downcase! }
    @deactivated_locations.sort_by!(&:location_name)

    render :admin_locations
  end

  def admin_item_types
    @item_types = ItemType.all
    @actived_item_types = @item_types.select(&:type_active)
    @actived_item_types.each { |item_type| item_type.type_name.downcase! }
    @actived_item_types.sort_by!(&:type_name)

    @deactivated_item_types = @item_types.reject(&:type_active)
    @deactivated_item_types.each { |item_type| item_type.type_name.downcase! }
    @deactivated_item_types.sort_by!(&:type_name)

    render :admin_item_types
  end

  def admin_purge
    render :admin_purge
  end

  def admin
    @locations = Location.all
    @actived_locations = @locations.select(&:location_active)
    @deactivated_locations = @locations.reject(&:location_active)

    @item_types = ItemType.all
    @actived_item_types = @item_types.select(&:type_active)
    @deactivated_item_types = @item_types.reject(&:type_active)

    render :admin
  end
end
