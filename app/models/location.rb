class Location < ApplicationRecord
  # TODO: enforce case-insensitive uniqueness w/o mangling user-entered names
  validates :location_name, presence: true, allow_blank: false, uniqueness: true

  scope :active, -> { where(location_active: true) } # TODO: just rename the columns
  scope :inactive, -> { where(location_active: false) }
end
