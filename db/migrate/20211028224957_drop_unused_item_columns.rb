class DropUnusedItemColumns < ActiveRecord::Migration[6.1]
  def up
    remove_column :items, :libID
    remove_column :items, :itemObsolete
    remove_column :items, :itemLastModified
    remove_column :items, :itemImage
  end

  def down
    add_column :items, :libID, :integer
    add_column :items, :itemObsolete, :integer
    add_column :items, :itemLastModified, :datetime
    add_column :items, :itemImage, :string

    Item.find_each do |item|
      item.update(itemLastModified: item.updated_at)
    end
  end
end
