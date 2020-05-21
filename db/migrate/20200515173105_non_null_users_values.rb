class NonNullUsersValues < ActiveRecord::Migration[6.0]
  def change
    change_column :users, :user_name, :string, :default => "unknown", :null => false
    change_column :users, :uid, :integer, :default => 0, :null => false
  end
end
