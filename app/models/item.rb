class Item < ApplicationRecord
  has_paper_trail
  validates :itemDescription, presence: true, allow_blank: false
  validates :whereFound, presence: true, allow_blank: false
  has_one_attached :image
    attr_accessor :locations
    attr_accessor :types
    attribute :itemStatus, :integer, default: 1
    paginates_per 25

    def locations
      @locations = Location.all
    end

    def types
      @types = ItemType.all
    end


      scope :claimed, -> { where("itemStatus = 3 or claimedBy = 'Purged'")}
      scope :found, -> { where("itemStatus = 1 and claimedBy != 'Purged'")}
      scope :query_params, -> (searchText) { 
        keywords = searchText.split(' ')
        where((['itemDescription LIKE ?'] * keywords.size).join(' OR '), *keywords.map{ |keyword| "%#{keyword}%" })
      }
  end