class ItemType < ApplicationRecord
  # TODO: enforce case-insensitive uniqueness w/o mangling user-entered names
  validates :type_name, presence: true, allow_blank: false, uniqueness: true

  scope :active, -> { where(type_active: true) } # TODO: just rename the columns
  scope :inactive, -> { where(type_active: false) }

  scope :editable, -> { where.not(type_name: 'other') }
end
