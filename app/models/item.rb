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

  def claimed?
    # TODO: replace magic number with enum
    status == 3 || !claimed_by.nil?
  end

  class << self
    def by_keywords(keywords)
      keywords = clean_keywords(keywords)
      return Item if keywords.empty?

      # POSIX/Postgres regex syntax isn't exactly Ruby but hopefully close enough for escapes
      keyword_re_fragments = keywords.map { |kw| "\\m#{Regexp.escape(kw)}\\M" }
      keyword_re = "(#{keyword_re_fragments.join('|')})"

      Item.where('description ~* ?', keyword_re)
    end

    private

    def clean_keywords(keywords)
      return [] unless keywords

      keywords.lazy.map(&:strip).reject(&:empty?).sort.uniq
    end
  end

end
