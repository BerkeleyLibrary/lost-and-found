class NonNullUsersValues < ActiveRecord::Migration[6.0]
  def change
    change_column :users, :user_name, :string, :default => "unknown", :null => false
    change_column :users, :uid, 'integer USING CAST(uid AS integer)'
  end
end
