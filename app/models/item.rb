class Item < ApplicationRecord
    scope :claimed, -> { where("itemStatus = 3")}
    scope :found, -> { where("itemStatus = 1")}
    scope :query_params, lambda {|params| where("itemDescription LIKE ?", "%#{params[:keyword]}%") } 
  end
