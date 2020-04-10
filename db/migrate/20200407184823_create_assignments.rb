class CreateAssignments < ActiveRecord::Migration[6.0]
  def change
    create_table :assignments do |t|
      t.string :user, null: false, foreign_key: true
      t.string :role, null: false, foreign_key: true

      t.timestamps
    end
  end
end
