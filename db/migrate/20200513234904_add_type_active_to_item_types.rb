class AddTypeActiveToItemTypes < ActiveRecord::Migration[6.0]
  def change
    add_column :item_types, :type_active, :boolean
  end
end
