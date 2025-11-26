# TODO: split into HomeController & AdminController
class HomeController < ApplicationController
  before_action :logout_if_expired!
  before_action :require_admin!

  def admin_users
    @active_users = User.active
    @inactive_users = User.inactive
  end

  def admin_locations
    @active_locations = Location.active.order(:location_name)
    @inactive_locations = Location.inactive.order(:location_name)
  end

  def admin_item_types
    editable_item_types = ItemType.editable
    @active_item_types = editable_item_types.active.order(:type_name)
    @inactive_item_types = editable_item_types.inactive.order(:type_name)
  end

  def admin_purge
    # placeholder for view
  end

  def admin
    # placeholder for view
  end
end
