class LocationsController < ApplicationController
  before_action :logout_if_expired!
  before_action :require_admin!

  def create
    # TODO: enforce case-insensitive uniqueness w/o mangling user-entered names
    #       - see https://stackoverflow.com/a/2223789/27358

    @location = Location.new
    @location.location_name = params[:location_name].downcase
    @location.location_active = true
    @location.updated_at = Time.now
    @location.updated_by = current_user.user_name

    begin
      if @location.valid? && @location.save!
        @locations = Location.all
        flash[:success] = "Success: Location #{@location.location_name} added"
        redirect_back(fallback_location: login_path)
      else
        @locations = Location.all
        flash[:alert] = "Error: Location #{@location.location_name.titleize} already exists"
        redirect_back(fallback_location: login_path)
      end
    rescue Exception => e
      @locations = Location.all
      flash[:alert] = "Error: Location #{@location.location_name.titleize} failed to be added"
      redirect_back(fallback_location: login_path)
    end
  end

  def edit
    @location = Location.find(params[:id])
  end

  def update
    active = params[:location_active] == 'true'
    @location = Location.find(params[:id])
    @location.update(location_name: params[:location_name].downcase, location_active: active, updated_at: Time.now, updated_by: current_user.user_name)
    @locations = Location.all
    redirect_to admin_locations_path
  rescue Exception => e
    flash[:alert] = "Error: Location #{params[:location_name].titleize} failed to be added"
    redirect_to admin_locations_path
  end

  def change_status
    @location = Location.find(params[:id])
    @location.update(location_active: !@location.location_active, updated_by: current_user.user_name)
    @locations = Location.all
    flash[:success] = "Success: Location #{@location.location_name.titleize} status updated!"
    redirect_back(fallback_location: login_path)
  end
end
