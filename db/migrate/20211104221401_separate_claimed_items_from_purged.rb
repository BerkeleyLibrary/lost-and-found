class SeparateClaimedItemsFromPurged < ActiveRecord::Migration[6.1]
  def up
    add_column(:items, :purged, :boolean, null: false, default: false)
    add_column(:items, :claimed, :boolean, null: false, default: false)
    remove_column(:items, :status)

    Item.find_each do |item|
      claimed_by = item.claimed_by
      if claimed_by.blank?
        item.claimed_by = nil
      elsif claimed_by == 'Purged'
        item.claimed_by = nil
        item.purged = true
      else
        item.claimed = true
      end
      item.save(validate: false)
    end

  end

  def down
    Item.where(purged: true).update_all(claimed_by: 'Purged')

    add_column(:items, :status, :integer)
    Item.where(claimed_by: nil).update_all(status: 1)
    Item.where.not(claimed_by: nil).update_all(status: 3)

    remove_column(:items, :purged)
    remove_column(:items, :claimed)
  end
end
