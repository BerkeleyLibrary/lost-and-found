class CreateStatuses < ActiveRecord::Migration[6.0]
  def up
    create_table "statuses", primary_key: "statusID", id: :integer, options: "ENGINE=MyISAM DEFAULT CHARSET=latin1", force: :cascade do |t|
      t.text "statusName", null: false
    end
  end
  def down
  end
end
