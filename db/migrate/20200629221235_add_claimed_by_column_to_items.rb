class AddClaimedByColumnToItems < ActiveRecord::Migration[6.0]
  def change
    add_column :items, :claimedBy, :string
  end
end
