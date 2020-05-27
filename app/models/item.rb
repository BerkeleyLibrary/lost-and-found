class Item < ApplicationRecord
  has_one_attached :image
    attr_accessor :locations
    attr_accessor :types
  

    def locations
      @locations = Location.all
    end

    def types
      @types = ItemType.all
    end


      scope :claimed, -> { where("itemStatus = 3")}
      scope :found, -> { where("itemStatus = 1")}
      scope :query_params, -> (params ) {
        unless params[:searchAll]
         where("itemType = ? AND itemDescription LIKE ? AND itemLocation = ?", "#{params[:itemType]}","%#{params[:keyword]}%", "#{params[:itemLocation]}")
        else
          where("itemType = ? AND itemDescription LIKE ?  ", "#{params[:itemType]}", "%#{params[:keyword]}%")
        end
        }
  end