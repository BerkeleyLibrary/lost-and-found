# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_04_07_184823) do

  create_table "assignments", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "user", null: false
    t.string "role", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "item_types", primary_key: "typeID", id: :integer, options: "ENGINE=MyISAM DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.text "typeName", null: false
  end

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

  create_table "libraries", primary_key: "libID", id: :integer, options: "ENGINE=MyISAM DEFAULT CHARSET=latin1", comment: "Library info table", force: :cascade do |t|
    t.string "libName", null: false
  end

  create_table "locations", primary_key: "locationID", id: :integer, options: "ENGINE=MyISAM DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.text "locationName", null: false
    t.integer "libID", null: false
  end

  create_table "months", primary_key: "monthNum", id: :integer, default: nil, options: "ENGINE=MyISAM DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.text "month", null: false
  end

  create_table "statuses", primary_key: "statusID", id: :integer, options: "ENGINE=MyISAM DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.text "statusName", null: false
  end

  create_table "users", primary_key: "Username", id: :string, limit: 15, options: "ENGINE=MyISAM DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "Password", limit: 15, null: false
    t.integer "libID", null: false
  end

end
