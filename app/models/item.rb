class Item < ApplicationRecord
  has_paper_trail
  validates :date_found, presence: true
  validates :description, presence: true, allow_blank: false
  validates :item_type, presence: true, allow_blank: false
  validates :location, presence: true, allow_blank: false
  validates :where_found, presence: true, allow_blank: false
  validates :claimed_by, presence: true, allow_blank: false, if: :claimed?

  has_one_attached :image

  paginates_per 25

  scope :claimed, -> { where(claimed: true) }
  scope :purged, -> { where(purged: true) }
  scope :unclaimed, -> { where(claimed: false, purged: false) }

  class << self
    def by_keywords(keywords)
      keywords = clean_keywords(keywords)
      return Item.unclaimed if keywords.empty?

      # POSIX/Postgres regex syntax isn't exactly Ruby but hopefully close enough for escapes
      keyword_re_fragments = keywords.map { |kw| "\\m#{Regexp.escape(kw)}\\M" }
      keyword_re = "(#{keyword_re_fragments.join('|')})"

      Item.unclaimed.where('description ~* ?', keyword_re)
    end

    private

    def clean_keywords(keywords)
      return [] unless keywords

      keywords.lazy.map(&:strip).reject(&:empty?).sort.uniq
    end
  end

end
