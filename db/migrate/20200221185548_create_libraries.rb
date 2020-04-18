class CreateLibraries < ActiveRecord::Migration[6.0]
  def up
    create_table "libraries", primary_key: "libID", id: :integer, options: "ENGINE=MyISAM DEFAULT CHARSET=latin1", comment: "Library info table", force: :cascade do |t|
      t.string "libName", null: false
    end
  end
  def down
  end
end
