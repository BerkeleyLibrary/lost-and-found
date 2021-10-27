# TODO: merge into ItemsController
class FormsController < ApplicationController
  def search_form
    @locations_layout = location_setup
    @item_type_layout = item_type_setup

    render :search_form
  end

  def insert_form
    @locations_layout = location_setup []
    @item_type_layout = item_type_setup []

    render :insert_form
  end
end
