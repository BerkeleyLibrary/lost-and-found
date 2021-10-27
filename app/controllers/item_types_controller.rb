class ItemTypesController < ApplicationController
  before_action :logout_if_expired!
  before_action :require_admin!

  def all
    @item_types = ItemType.all
  end

  def create
    @ItemType = ItemType.new
    # TODO: enforce case-insensitive uniqueness w/o mangling user-entered names
    @ItemType.type_name = params[:type_name].downcase
    @ItemType.type_active = true
    @ItemType.updated_at = Time.now
    @ItemType.updated_by = current_user.user_name

    begin
      if @ItemType.valid? && @ItemType.save!
        @item_types = ItemType.all
        flash[:success] = "Success: Item Type #{@ItemType.type_name} added"
        redirect_back(fallback_location: login_path)
      else
        @item_types = ItemType.all
        flash[:alert] = "Error: Item Type #{@ItemType.type_name.titleize} already exists"
        redirect_back(fallback_location: login_path)
      end
    rescue Exception => e
      @item_types = ItemType.all
      flash[:alert] = "Error: Item Type #{@ItemType.type_name.titleize} failed to be added"
      redirect_back(fallback_location: login_path)
    end
  end

  def edit
    @itemType = ItemType.find(params[:id])
  end

  def update
    active = params[:type_active] == 'true'
    @itemType = ItemType.find(params[:id])
    @itemType.update(type_name: params[:type_name].downcase, type_active: active, updated_at: Time.now, updated_by: current_user.user_name)
    @itemTypes = ItemType.all
    redirect_to admin_item_types_path
  rescue StandardError
    flash[:alert] = "Error: Item type #{params[:type_name].titleize} failed to be added"
    redirect_to admin_item_types_path
  end

  def change_status
    @itemType = ItemType.find(params[:id])
    @itemType.update(type_active: !@itemType.type_active, updated_by: current_user.user_name)
    @itemTypes = ItemType.all
    flash[:success] = "Success: Item type #{@itemType.type_name.titleize} status updated!"
    redirect_back(fallback_location: login_path)
  end
end
