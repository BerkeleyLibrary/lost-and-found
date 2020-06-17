class LocationsController < ApplicationController

    def all
      @Locations = Location.all
      render template: "items/all"
    end

    def create
      @Location = Location.new()
      @Location.location_name = params[:location_name]
      @Location.location_active = true
      @Location.updated_at = Time.now();
      @Location.updated_by = cookies[:user_name]

      if @Location.save!
        @Locations = Location.all
        redirect_back(fallback_location: root_path)
      else
        @Locations = Location.all
        redirect_back(fallback_location: root_path)
      end
    end

    def edit
      @location = Location.find(params[:id])
    end



    def update
      active = params[:location_active] == "true"
      @location = Location.find(params[:id])
      @location.update(location_name: params[:location_name], location_active: active, updated_at: Time.now(), updated_by: cookies[:user_name])
      @locations = Location.all
      redirect_to admin_locations_path
    end

    def change_status
      @location = Location.find(params[:id])
      @location.update(location_active: !@location.location_active)
      @locations = Location.all
      redirect_back(fallback_location: root_path)
    end

    def destroy
      Location.delete(params[:id])
      @Locations = Location.all
      redirect_back(fallback_location: root_path)
    end
  end