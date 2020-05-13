class AddUserActiveToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :user_active, :boolean
  end
end
