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
  scope :found, -> { where(status: 1).where(claimed_by: nil).or(Item.where.not(claimed_by: 'Purged')) } # TODO: is this right?

  scope :by_keywords, ->(keywords) {
    return Item if keywords.nil? || keywords.empty?

    conditions = keywords.filter_map do |keyword|
      Item.where('description LIKE ?', "%#{keyword}%") unless keyword.blank?
    end

    conditions.inject do |query, condition|
      query.or(condition)
    end
  }

  def claimed?
    # TODO: replace magic number with enum
    status == 3 || !claimed_by.nil?
  end
end
