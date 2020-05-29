class AddUpdatedByColumnToLocations < ActiveRecord::Migration[6.0]
  def change
    add_column :locations, :updated_by, :string
  end
end
