class Item < ApplicationRecord
    attr_accessor :locations
    attr_accessor :types
  
    def locations
      @locations || [
        'No location submitted',
        'Doe Circle',
        'Doe North Entrance',
        'Doe South Entrance',
        'Gardner Stacks',
        'Library Security',
        'Moffit Third Floor',
        'Moffit forth Floor',
        'Moffit Circle',
        'MRC',
        'Privileges Desk',
        'UCPD'
      ]
    end
  
    def types
      @types || [
        'none',
        'book',
        'clothing',
        'electronics',
        'glasses',
        'id',
        'keys',
        'mp3',
        'other',
      ]
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