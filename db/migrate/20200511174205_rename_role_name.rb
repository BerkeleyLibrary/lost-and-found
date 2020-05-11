class RenameRoleName < ActiveRecord::Migration[6.0]
  def change
    rename_column :roles, :rolename, :role_name
    rename_column :roles, :level, :role_level
  end
end
