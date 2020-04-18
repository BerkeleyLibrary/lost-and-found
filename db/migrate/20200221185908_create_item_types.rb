class CreateItemTypes < ActiveRecord::Migration[6.0]
  def up
    create_table "item_types", primary_key: "typeID", id: :integer, options: "ENGINE=MyISAM DEFAULT CHARSET=latin1", force: :cascade do |t|
      t.text "typeName", null: false
    end
  end
  def down
  end
end
