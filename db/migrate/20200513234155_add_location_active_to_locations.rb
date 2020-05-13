class AddLocationActiveToLocations < ActiveRecord::Migration[6.0]
  def change
    add_column :locations, :location_active, :boolean
  end
end
