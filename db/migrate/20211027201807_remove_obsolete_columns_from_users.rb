class RemoveObsoleteColumnsFromUsers < ActiveRecord::Migration[6.1]
  def change
    remove_columns(:users, :remember_created_at, :provider)
    Item.reset_column_information
  end
end
