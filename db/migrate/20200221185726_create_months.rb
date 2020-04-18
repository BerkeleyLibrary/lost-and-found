class CreateMonths < ActiveRecord::Migration[6.0]
  def up
    create_table "months", primary_key: "monthNum", id: :integer, default: nil, options: "ENGINE=MyISAM DEFAULT CHARSET=latin1", force: :cascade do |t|
      t.text "month", null: false
    end
  end
  def down
  end
end
