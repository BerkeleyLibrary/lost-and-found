class AddColumnOfUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :uid, :string, unique: true
  end
end
