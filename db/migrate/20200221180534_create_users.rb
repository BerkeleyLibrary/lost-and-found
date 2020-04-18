class CreateUsers < ActiveRecord::Migration[6.0]
  def up
    create_table "users", primary_key: "Username", id: :string, limit: 15, options: "ENGINE=MyISAM DEFAULT CHARSET=latin1", force: :cascade do |t|
      t.string "Password", limit: 15, null: false
      t.integer "libID", null: false
    end
  end
  def down
  end
end
