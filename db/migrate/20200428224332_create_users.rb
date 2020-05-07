class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string :user_name
      t.string :uid
      t.string :user_role
      t.timestamps
    end
  end
end
