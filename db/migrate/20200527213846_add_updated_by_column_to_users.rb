class AddUpdatedByColumnToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :updated_by, :string
  end
end
