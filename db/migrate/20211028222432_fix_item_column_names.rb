class FixItemColumnNames < ActiveRecord::Migration[6.1]
  COLUMNS = {
    claimed_by: :claimedBy,
    date_found: :itemDate,
    description: :itemDescription,
    entered_by: :itemEnteredBy,
    found_at: :itemFoundAt,
    found_by: :itemFoundBy,
    item_type: :itemType,
    location: :itemLocation,
    status: :itemStatus,
    updated_by: :itemUpdatedBy,
    where_found: :whereFound
  }

  def up
    COLUMNS.each do |right, wrong|
      rename_column :items, wrong, right
    end
    Item.reset_column_information
  end

  def down
    COLUMNS.each do |right, wrong|
      rename_column :items, right, wrong
    end
    Item.reset_column_information
  end
end
