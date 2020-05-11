class FormsController < ApplicationController
    def search_form
      @locations_layout = location_setup
      @item_type_layout = item_type_setup

      render :search_form
    end

    def insert_form
      @locations_layout = location_setup
      @item_type_layout = item_type_setup

      render :insert_form
    end

    private
      def location_setup
        locations = Location.all
        locations_layout = []
        locations.each do |location|
          locations_layout.push([location.location_name,location.location_name])
        end
        locations_layout
      end

      def item_type_setup
        item_types = ItemType.all
        item_type_layout = []

        item_types.each do |type|
          item_type_layout.push([type.type_name, type.type_name])
        end
        item_type_layout
      end
end