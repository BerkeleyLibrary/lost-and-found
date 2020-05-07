class ItemTypesController < ApplicationController

    def all
      @item_types = ItemType.all
    end

    def create
      @ItemType = ItemType.new()
      @ItemType.type_name = params[:type_name]
      @ItemType.type_description = params[:type_description]

      if @ItemType.save!
        @item_types = ItemType.all
        redirect_back(fallback_location: root_path)
      else
        @item_types = ItemType.all
        redirect_back(fallback_location: root_path)
      end
    end

    def destroy
        ItemType.delete(params[:id])
        @ItemTypes = ItemType.all
        redirect_back(fallback_location: root_path)
    end
end