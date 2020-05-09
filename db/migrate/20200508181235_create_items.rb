  class CreateItems < ActiveRecord::Migration[6.0]
    def change
      create_table :items do |t|
        t.datetime "itemDate"
        t.datetime "itemFoundAt"
        t.string "itemLocation"
        t.string "itemType"
        t.string "itemDescription"
        t.datetime "itemLastModified"
        t.integer "itemStatus"
        t.string "itemEnteredBy"
        t.string "itemImage"
        t.integer "itemObsolete"
        t.string "itemUpdatedBy"
        t.string "itemFoundBy"
        t.integer "libID"

        t.timestamps
      end
    end
  end