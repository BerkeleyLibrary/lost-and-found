class ItemType < ApplicationRecord
    validates :type_name, presence: true, allow_blank: false
    scope :active, -> { where("type_active = true")}
end
