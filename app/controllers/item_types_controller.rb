class ItemTypesController < ApplicationController

  def all
    @item_types = ItemType.all
  end

  def create
    @ItemType = ItemType.new
    # TODO: enforce case-insensitive uniqueness w/o mangling user-entered names
    #       - see https://stackoverflow.com/a/2223789/27358
    @ItemType.type_name = params[:type_name].downcase
    @ItemType.type_active = true
    @ItemType.updated_at = Time.now
    @ItemType.updated_by = session[:user_name]

    begin
      if @ItemType.valid? && @ItemType.save!
        @item_types = ItemType.all
        flash[:success] = "Success: Item Type #{@ItemType.type_name} added"
        redirect_back(fallback_location: root_path)
      else
        @item_types = ItemType.all
        flash[:alert] = "Error: Item Type #{@ItemType.type_name.titleize} already exists"
        redirect_back(fallback_location: root_path)
      end
    rescue Exception => e
      @item_types = ItemType.all
      flash[:alert] = "Error: Item Type #{@ItemType.type_name.titleize} failed to be added"
      redirect_back(fallback_location: root_path)
    end
  end

  def edit
    @itemType = ItemType.find(params[:id])
  end

  def update
    active = params[:type_active] == 'true'
    @itemType = ItemType.find(params[:id])
    @itemType.update(type_name: params[:type_name].downcase, type_active: active, updated_at: Time.now, updated_by: session[:user_name])
    @itemTypes = ItemType.all
    redirect_to admin_item_types_path
  rescue StandardError
    flash[:alert] = "Error: Item type #{params[:type_name].titleize} failed to be added"
    redirect_to admin_item_types_path
  end

  def change_status
    @itemType = ItemType.find(params[:id])
    @itemType.update(type_active: !@itemType.type_active, updated_by: session[:user_name])
    @itemTypes = ItemType.all
    flash[:success] = "Success: Item type #{@itemType.type_name.titleize} status updated!"
    redirect_back(fallback_location: root_path)
  end

  def batch_upload
    if params[:batch_file] != nil
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

        @ItemType = ItemType.new
        @ItemType.type_name = modified_item_values[1].downcase
        @ItemType.type_active = true
        @ItemType.updated_at = Time.now
        @ItemType.updated_by = 'Legacy'
        begin
          @ItemType.save!
        rescue StandardError
        end
      end
      redirect_to admin_item_types_path
      flash[:success] = "Success: item types added"
    else
      redirect_to admin_item_types_path
      flash[:alert] = "Error: File unreadable"
    end
  end
end
