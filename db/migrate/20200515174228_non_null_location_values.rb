class NonNullLocationValues < ActiveRecord::Migration[6.0]
  def change
    change_column :locations, :location_name, :string, :default => "unknown", :null => false
  end
end
