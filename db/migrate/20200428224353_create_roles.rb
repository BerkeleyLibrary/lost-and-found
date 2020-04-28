class CreateRoles < ActiveRecord::Migration[6.0]
  def change
    create_table :roles do |t|
      t.string :rolename
      t.string :level

      t.timestamps
    end
  end
end
