class Item < ApplicationRecord
  attr_accessor :locations

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
    scope :claimed, -> { where("itemStatus = 3")}
    scope :found, -> { where("itemStatus = 1")}
    scope :query_params, lambda {
      |params| where(
      "itemDescription LIKE ?  AND itemLocation = ?", "%#{params[:keyword]}%", "#{params[:itemLocation]}")
    }
  end
