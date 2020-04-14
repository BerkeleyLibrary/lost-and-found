class Item < ApplicationRecord
    belongs_to :itemTypes
    scope :claimed, -> { where('itemStatus = 3') }
    scope :found, -> { where('itemStatus = 1') }
    scope :search, ->(query) { where(['itemLocation = ?', query.to_s]) }
end
