class ChangeUidType < ActiveRecord::Migration[6.0]
  def change
    change_column :users, :uid, 'integer USING CAST(uid AS integer)'
  end
end
