class NonNullItemTypesValues < ActiveRecord::Migration[6.0]
  def change
    change_column :item_types, :type_name, :string, :default => "unknown", :null => false
    change_column :item_types, :type_description, :string, :default => "No description", :null => false
  end
end
