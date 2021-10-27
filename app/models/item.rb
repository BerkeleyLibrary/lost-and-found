class Item < ApplicationRecord
  has_paper_trail
  validates :itemDescription, presence: true, allow_blank: false
  validates :whereFound, presence: true, allow_blank: false
  has_one_attached :image
  attr_accessor :locations
  attr_accessor :types

  attribute :itemStatus, :integer, default: 1 # TODO: replace magic number with enum
  paginates_per 25

  # TODO: clean this up
  scope :claimed, -> { where(itemStatus: 3).or(where(claimedBy: 'Purged')) }
  scope :found, -> { where(itemStatus: 1).where.not(claimedBy: 'Purged') }

  scope :query_params, ->(searchText) {
    keywords = searchText.split(' ')
    arel = Item.arel_table
    records = []
    keywords.each do |keyword|
      like_ast = arel[:itemDescription].matches("%#{keyword}%")
      records += Item.where(like_ast)
    end
    records
  }

  def claimed?
    # TODO: replace magic number with enum
    itemStatus == 3 || claimedBy != nil
  end
end
