class CreateTestModels < ActiveRecord::Migration[6.0]
  def change
    create_table :test_models do |t|
      t.string :fieldA
      t.string :fieldB

      t.timestamps
    end
  end
end
