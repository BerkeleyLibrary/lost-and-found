class LocationsController < ApplicationController

  def create
    # TODO: enforce case-insensitive uniqueness w/o mangling user-entered names
    #       - see https://stackoverflow.com/a/2223789/27358

    @Location = Location.new
    @Location.location_name = params[:location_name].downcase
    @Location.location_active = true
    @Location.updated_at = Time.now
    @Location.updated_by = session[:user_name]

    begin
      if @Location.valid? && @Location.save!
        @Locations = Location.all
        flash[:success] = "Success: Location #{@Location.location_name} added"
        redirect_back(fallback_location: root_path)
      else
        @Locations = Location.all
        flash[:alert] = "Error: Location #{@Location.location_name.titleize} already exists"
        redirect_back(fallback_location: root_path)
      end
    rescue Exception => e
      @Locations = Location.all
      flash[:alert] = "Error: Location #{@Location.location_name.titleize} failed to be added"
      redirect_back(fallback_location: root_path)
    end
  end

  def edit
    @location = Location.find(params[:id])
  end

  def update
    active = params[:location_active] == 'true'
    @location = Location.find(params[:id])
    @location.update(location_name: params[:location_name].downcase, location_active: active, updated_at: Time.now, updated_by: session[:user_name])
    @locations = Location.all
    redirect_to admin_locations_path
  rescue Exception => e
    flash[:alert] = "Error: Location #{params[:location_name].titleize} failed to be added"
    redirect_to admin_locations_path
  end

  def change_status
    @location = Location.find(params[:id])
    @location.update(location_active: !@location.location_active, updated_by: session[:user_name])
    @locations = Location.all
    flash[:success] = "Success: Location #{@location.location_name.titleize} status updated!"
    redirect_back(fallback_location: root_path)
  end
end
