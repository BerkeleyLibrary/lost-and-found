class SeparateClaimedItemsFromPurged < ActiveRecord::Migration[6.1]
  def up
    rename_column(:items, :status, :legacy_status)
    rename_column(:items, :claimed_by, :legacy_claimed_by)
    add_column(:items, :claimed_by, :string)
    add_column(:items, :purged, :boolean, null: false, default: false)
    add_column(:items, :claimed, :boolean, null: false, default: false)

    [
      "UPDATE items SET claimed_by = legacy_claimed_by",
      "UPDATE items SET claimed_by = NULL WHERE claimed_by = ''",
      "UPDATE items SET purged = true, claimed_by = NULL WHERE claimed_by ~* 'purged'",
      "UPDATE items SET claimed = true WHERE claimed_by IS NOT NULL"
    ].each do |stmt|
      Item.connection.execute(stmt)
    end
  end

  def down
    remove_column(:items, :claimed)
    remove_column(:items, :purged)
    remove_column(:items, :claimed_by)
    rename_column(:items, :legacy_claimed_by, :claimed_by)
    rename_column(:items, :legacy_status, :status)
  end
end
