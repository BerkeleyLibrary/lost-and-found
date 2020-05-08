class CreateItemTypes < ActiveRecord::Migration[6.0]
  def change
    create_table :item_types do |t|
      t.string :type_name
      t.string :type_description

      t.timestamps
    end
  end
end
