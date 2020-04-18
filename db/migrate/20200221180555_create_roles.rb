class CreateRoles < ActiveRecord::Migration[6.0]
  def up
    create_table "roles", primary_key: ["Username", "Rolename"], options: "ENGINE=MyISAM DEFAULT CHARSET=latin1", force: :cascade do |t|
      t.string "Username", limit: 15, null: false
      t.string "Rolename", limit: 15, null: false
      t.integer "libID", null: false
    end
  end
  def down
  end
end
