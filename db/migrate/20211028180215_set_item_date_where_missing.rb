class SetItemDateWhereMissing < ActiveRecord::Migration[6.1]
  def change
    Item.where(itemDate: nil).find_each do |item|
      item.itemDate = item.created_at.to_date
      item.save!(validate: false, touch: false)
    end
  end
end
