class DropResetColumnsFromUsers < ActiveRecord::Migration[6.0]
  def change
    remove_column :users, :reset_password_token
  end
end
