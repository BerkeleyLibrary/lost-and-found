class ItemType < ApplicationRecord
    scope :active, -> { where("type_active = true")}
end
