class Location < ApplicationRecord
  # TODO: enforce case-insensitive uniqueness w/o mangling user-entered names
  #       - see https://stackoverflow.com/a/2223789/27358
  validates :location_name, presence: true, allow_blank: false, :uniqueness => true
  scope :active, -> { where("location_active = true") }
end
