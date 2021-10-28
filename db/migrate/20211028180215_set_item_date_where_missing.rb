class SetItemDateWhereMissing < ActiveRecord::Migration[6.1]
  def change
    Item.where(itemDate: nil).find_each do |item|
      item.update(itemDate: item.created_at.to_date)
    end
  end
end
