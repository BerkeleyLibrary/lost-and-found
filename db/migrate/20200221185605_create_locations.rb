class CreateLocations < ActiveRecord::Migration[6.0]
  def up
    create_table "locations", primary_key: "locationID", id: :integer, options: "ENGINE=MyISAM DEFAULT CHARSET=latin1", force: :cascade do |t|
      t.text "locationName", null: false
      t.integer "libID", null: false
    end
  end
  def down
  end
end
