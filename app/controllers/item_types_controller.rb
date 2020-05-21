class ItemTypesController < ApplicationController

    def all
      @item_types = ItemType.all
    end

    def create
      @ItemType = ItemType.new()
      @ItemType.type_name = params[:type_name]
      @ItemType.type_description = params[:type_description]
      @ItemType.type_active = true

      if @ItemType.save!
        @item_types = ItemType.all
        redirect_back(fallback_location: root_path)
      else
        @item_types = ItemType.all
        redirect_back(fallback_location: root_path)
      end
    end

    def edit
      @itemType = ItemType.find(params[:id])
    end

    def update
      active = params[:type_active] == "true"
      @itemType = ItemType.find(params[:id])
      @itemType.update(type_name: params[:type_name], type_description: params[:type_description], type_active: active)
      @itemTypes = ItemType.all
      redirect_to admin_item_types_path
    end

    def change_status
      @itemType = ItemType.find(params[:id])
      @itemType.update(type_active: !@itemType.type_active)
      @itemTypes = ItemType.all
      redirect_back(fallback_location: root_path)
    end

    def destroy
        ItemType.delete(params[:id])
        @ItemTypes = ItemType.all
        redirect_back(fallback_location: root_path)
    end
end