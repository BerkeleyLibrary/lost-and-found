class ChangeColumnOfUsers < ActiveRecord::Migration[6.0]
  def change
    remove_column :users, :uid
  end
end
