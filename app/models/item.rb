class Item < ApplicationRecord
  has_paper_trail
  validates :itemDescription, presence: true, allow_blank: false
  has_one_attached :image
    attr_accessor :locations
    attr_accessor :types
    attribute :itemStatus, :integer, default: 1

    def locations
      @locations = Location.all
    end

    def types
      @types = ItemType.all
    end


      scope :claimed, -> { where("itemStatus = 3")}
      scope :found, -> { where("itemStatus = 1")}
      scope :query_params, -> (searchText) { 
        keywords = searchText.split(' ')
        where((['itemDescription LIKE ?'] * keywords.size).join(' OR '), *keywords.map{ |keyword| "%#{keyword}%" })
      }
  end