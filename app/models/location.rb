class Location < ApplicationRecord
    validates :location_name, presence: true, allow_blank: false, :uniqueness => true
    scope :active, -> { where("location_active = true")}
end
