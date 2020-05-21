class DropPasswordColumnsFromUsers < ActiveRecord::Migration[6.0]
  def change
    remove_column :users, :encrypted_password
  end
end
