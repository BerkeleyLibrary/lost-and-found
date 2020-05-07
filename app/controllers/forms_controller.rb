class FormsController < ApplicationController
    def search_form
      render :search_form
    end

    def insert_form
      @locations = Location.all
      @locations_layout = []
      @locations.each do |location|
        @locations_layout.push([location.location_name,location.location_name])
      end

      @item_types = ItemType.all
      @item_type_layout = []

      @item_types.each do |type|
        @item_type_layout.push([type.type_name, type.type_name])
      end

      render :insert_form
    end

end