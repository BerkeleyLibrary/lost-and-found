class LocationsController < ApplicationController
  before_action :logout_if_expired!
  before_action :require_admin!

  # TODO: clean this up further
  # rubocop:disable Metrics/MethodLength
  def create
    # TODO: enforce case-insensitive uniqueness w/o mangling user-entered names
    location = Location.new(
      location_name: params[:location_name].downcase,
      location_active: true,
      updated_by: current_user.user_name
    )

    begin
      location.save!
      # TODO: enforce case-insensitive uniqueness w/o mangling user-entered names
      flash[:success] = "Location #{location.location_name.titleize} added"
    rescue StandardError => e
      flash_errors(location, e)
    end

    redirect_to(admin_locations_path)
  end
  # rubocop:enable Metrics/MethodLength

  def edit
    @location = Location.find(params[:id])
  end

  # TODO: clean this up further
  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def update
    # TODO: enforce case-insensitive uniqueness w/o mangling user-entered names
    location = Location.find(params[:id])
    begin
      location.update!(
        location_name: params[:location_name].downcase,
        location_active: (params[:location_active] == '1'),
        updated_by: current_user.user_name
      )
      # TODO: enforce case-insensitive uniqueness w/o mangling user-entered names
      flash[:success] = "Location #{location.location_name.titleize} updated"
    rescue StandardError => e
      flash_errors(location, e)
    end

    redirect_to admin_locations_path
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

  def change_status
    location = Location.find(params[:id])
    location.update!(
      location_active: !location.location_active,
      updated_by: current_user.user_name
    )

    # TODO: enforce case-insensitive uniqueness w/o mangling user-entered names
    flash[:success] = "Location #{location.location_name.titleize} #{location.location_active? ? 'activated' : 'deactivated'}"
    redirect_to admin_locations_path
  end
end
