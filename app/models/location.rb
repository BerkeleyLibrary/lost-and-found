class Location < ApplicationRecord
    scope :active, -> { where("location_active = true")}
end
