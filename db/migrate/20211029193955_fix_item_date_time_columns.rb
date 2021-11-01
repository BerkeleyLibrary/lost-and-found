class FixItemDateTimeColumns < ActiveRecord::Migration[6.1]
  def up
    rename_column(:items, :date_found, :legacy_date_found)
    rename_column(:items, :found_at, :legacy_time_found)

    change_table :items do |t|
      t.column(:date_found, :date)
      t.column(:datetime_found, :datetime)
    end

    Item.find_each do |item|
      date_found = (item.legacy_date_found || item.created_at).utc.to_date
      datetime_found = datetime_found(date_found, item.legacy_time_found)

      item.update(date_found: date_found, datetime_found: datetime_found)
    end
    Item.reset_column_information
  end

  def down
    remove_columns(:items, :date_found, :datetime_found)
    rename_column(:items, :legacy_date_found, :date_found)
    rename_column(:items, :legacy_time_found, :found_at)
    Item.reset_column_information
  end

  private

  def datetime_found(date_found, time_found)
    return unless date_found && time_found

    year, month, day = [:year, :month, :day].map { |attr| date_found.send(attr) }
    hour, min, sec = [:hour, :min, :sec].map { |attr| time_found.send(attr) }
    offset = time_found.strftime('%:z')

    DateTime.new(year, month, day, hour, min, sec, offset)
  end
end
