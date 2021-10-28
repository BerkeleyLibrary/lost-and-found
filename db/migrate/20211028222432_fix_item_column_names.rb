class FixItemColumnNames < ActiveRecord::Migration[6.1]
  COLUMNS = {
    claimed_by: :claimedBy,
    date: :itemDate,
    description: :itemDescription,
    entered_by: :itemEnteredBy,
    found_at: :itemFoundAt,
    found_by: :itemFoundBy,
    image: :itemImage,
    location: :itemLocation,
    status: :itemStatus,
    type: :itemType,
    updated_by: :itemUpdatedBy,
    where_found: :whereFound
  }

  # TODO: drop libID, itemObsolete, itemLastModified

  def up
    COLUMNS.each do |right, wrong|
      rename_column :items, wrong, right
    end
  end

  def down
    COLUMNS.each do |right, wrong|
      rename_column :items, right, wrong
    end
  end
end
