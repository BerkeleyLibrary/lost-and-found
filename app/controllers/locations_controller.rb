class LocationsController < ApplicationController

  def all
    @Locations = Location.all
    render template: 'items/all'
  end

  def create
    @Location = Location.new
    @Location.location_name = params[:location_name].downcase
    @Location.location_active = true
    @Location.updated_at = Time.now
    @Location.updated_by = cookies[:user_name]

    begin
      if @Location.valid? && @Location.save!
        @Locations = Location.all
        flash[:success] = "Success: Location #{@Location.location_name} added"
        redirect_back(fallback_location: root_path)
      else
        @Locations = Location.all
        flash[:alert] = "Error: Location #{@Location.location_name.titleize} Already exists"
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
    @location.update(location_name: params[:location_name].downcase, location_active: active, updated_at: Time.now, updated_by: cookies[:user_name])
    @locations = Location.all
    redirect_to admin_locations_path
  rescue Exception => e
    flash[:alert] = "Error: Location #{params[:location_name].titleize} failed to be added"
    redirect_to admin_locations_path
  end

  def change_status
    @location = Location.find(params[:id])
    @location.update(location_active: !@location.location_active)
    @locations = Location.all
    flash[:success] = "Success: Item type #{@location.location_name.titleize} status updated!"
    redirect_back(fallback_location: root_path)
  end

  def destroy
    Location.delete(params[:id])
    @Locations = Location.all
    redirect_back(fallback_location: root_path)
  end

  def batch_upload
    uploaded_file = params[:batch_file]
    file_content = uploaded_file.read
    upload_items = file_content.split('),(')
    upload_items.each do |item|
      item[0] = '' if item[0] == '('
      item[item.length - 1] = '' if item[item.length - 1] == ')'
      raw_item_values = item.split(',')
      modified_item_values = []
      raw_item_values.each do |value|
        modified_item_values.push(value.gsub("'", '').strip)
      end

      @Location = Location.new
      @Location.location_name = modified_item_values[1].downcase
      @Location.location_active = true
      @Location.updated_at = Time.now
      @Location.updated_by = 'Legacy'
      begin
        @Location.save!
      rescue StandardError
      end
    end
   end

  end
