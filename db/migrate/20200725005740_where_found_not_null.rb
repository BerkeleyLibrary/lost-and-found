class WhereFoundNotNull < ActiveRecord::Migration[6.0]
  def change
    change_column_null :items, :whereFound, false, "No Description"
  end
end
