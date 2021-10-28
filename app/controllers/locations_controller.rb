class LocationsController < ApplicationController
  before_action :logout_if_expired!
  before_action :require_admin!

  def create
    # TODO: enforce case-insensitive uniqueness w/o mangling user-entered names
    location_name = params[:location_name].downcase

    location = Location.new(
      location_name: location_name,
      location_active: true,
      updated_by: current_user.user_name
    )

    begin
      location.save!
      # TODO: enforce case-insensitive uniqueness w/o mangling user-entered names
      flash[:success] = "Location #{location.location_name.titleize} added"
    rescue => e
      flash_errors(location, e)
    end

    redirect_to(admin_locations_path)
  end

  def edit
    @location = Location.find(params[:id])
  end

  def update
    # TODO: enforce case-insensitive uniqueness w/o mangling user-entered names
    location_name = params[:location_name].downcase

    location = Location.find(params[:id])
    begin
      location.update!(
        location_name: location_name,
        location_active: (params[:location_active] == 'true'),
        updated_by: current_user.user_name
      )
      # TODO: enforce case-insensitive uniqueness w/o mangling user-entered names
      flash[:success] = "Location #{location.location_name.titleize} updated"
    rescue => e
      flash_errors(location, e)
    end

    redirect_to admin_locations_path
  end

  def change_status
    location = Location.find(params[:id])
    location.update!(
      location_active: !location.location_active,
      updated_by: current_user.user_name
    )

    # TODO: enforce case-insensitive uniqueness w/o mangling user-entered names
    flash[:success] = "Location #{location.location_name.titleize} updated"
    redirect_to admin_locations_path
  end
end
