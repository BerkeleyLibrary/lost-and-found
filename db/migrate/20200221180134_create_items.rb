class CreateItems < ActiveRecord::Migration[6.0]
  def up
    create_table "items", primary_key: "itemID", id: :integer, options: "ENGINE=MyISAM DEFAULT CHARSET=latin1", comment: "Item table", force: :cascade do |t|
      t.date "itemDate", null: false, comment: "Date item was found"
      t.string "itemTime", comment: "Time item was found"
      t.text "itemFoundAt", null: false, comment: "Location the item was found at"
      t.integer "itemLocation", null: false, comment: "Location where the item is now"
      t.integer "itemType", null: false, comment: "Type of the item found"
      t.text "itemDescription", null: false, comment: "Description of the item"
      t.timestamp "itemLastModified", default: -> { "CURRENT_TIMESTAMP" }, null: false, comment: "Last Modified time and date"
      t.integer "itemStatus", null: false, comment: "Status of the item"
      t.string "itemEnteredBy", null: false, comment: "Name of person that entered in information"
      t.string "itemImage", default: "None", null: false, comment: "Image of the item"
      t.boolean "itemObsolete", default: false, null: false, comment: "Flags obsolete items"
      t.string "itemUpdatedBy"
      t.string "itemFoundBy"
      t.integer "libID", null: false
      t.datetime "created_at", precision: 6, null: false
      t.datetime "updated_at", precision: 6, null: false
    end
  end

  def down
  end
end
