class LocationsController < ApplicationController

    def all
      @Locations = Location.all
      render template: "items/all"
    end

    def create
      @Location = Location.new()
      @Location.location_name = params[:location_name]

      if @Location.save!
        @Locations = Location.all
        redirect_back(fallback_location: root_path)
      else
        @Locations = Location.all
        redirect_back(fallback_location: root_path)
      end
    end
  
    def destroy
      Location.delete(params[:id])
      @Locations = Location.all
      redirect_back(fallback_location: root_path)
    end
  end