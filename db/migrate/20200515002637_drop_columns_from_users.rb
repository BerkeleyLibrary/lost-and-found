class DropColumnsFromUsers < ActiveRecord::Migration[6.0]
  def change
    remove_column :users, :email
    remove_column :users, :reset_password_sent_at
  end
end
