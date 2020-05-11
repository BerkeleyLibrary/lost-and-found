class RenameUserName < ActiveRecord::Migration[6.0]
  def change
    rename_column :users, :name, :user_name
    remove_column :users, :password
  end
end
