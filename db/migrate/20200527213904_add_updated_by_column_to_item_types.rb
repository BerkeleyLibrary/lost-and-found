class AddUpdatedByColumnToItemTypes < ActiveRecord::Migration[6.0]
  def change
    add_column :item_types, :updated_by, :string
  end
end
