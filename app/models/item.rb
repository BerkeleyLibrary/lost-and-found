class Item < ApplicationRecord
  has_paper_trail
  validates :item_type, presence: true, allow_blank: false
  validates :description, presence: true, allow_blank: false
  validates :location, presence: true, allow_blank: false
  validates :where_found, presence: true, allow_blank: false
  validates :date_found, presence: true

  has_one_attached :image

  attribute :status, :integer, default: 1 # TODO: replace magic number with enum

  paginates_per 25

  # TODO: clean this up
  scope :claimed, -> { where(status: 3).or(where(claimed_by: 'Purged')) }
  scope :found, -> { where(status: 1).where.not(claimed_by: 'Purged') }

  scope :query_params, ->(searchText) {
    keywords = searchText.split
    arel = Item.arel_table
    records = []
    keywords.each do |keyword|
      like_ast = arel[:description].matches("%#{keyword}%")
      records += Item.where(like_ast)
    end
    records
  }

  def claimed?
    # TODO: replace magic number with enum
    status == 3 || !claimed_by.nil?
  end
end
