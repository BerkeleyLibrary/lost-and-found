class Location < ApplicationRecord
    validates :location_name, presence: true, allow_blank: false
    scope :active, -> { where("location_active = true")}
end
