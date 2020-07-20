class AddWhereFoundColumnToItems < ActiveRecord::Migration[6.0]
  def change
    add_column :items, :whereFound, :string
  end
end
