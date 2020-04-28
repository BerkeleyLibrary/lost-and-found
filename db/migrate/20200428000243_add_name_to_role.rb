class AddNameToRole < ActiveRecord::Migration[6.0]
  def change
    add_column :roles, :name, :string
  end
end
