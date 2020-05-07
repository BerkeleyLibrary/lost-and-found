class CreateRoles < ActiveRecord::Migration[6.0]
  def change
    create_table :roles do |t|
      t.string :role_name
      t.string :role_level
      t.timestamps
    end
  end
end
