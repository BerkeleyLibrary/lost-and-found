# TODO: merge into ItemsController
class FormsController < ApplicationController
  before_action :logout_if_expired!
  before_action :authenticate!
  before_action(:require_staff_or_admin!, except: :search_form)

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
