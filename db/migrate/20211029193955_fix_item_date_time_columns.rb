class FixItemDateTimeColumns < ActiveRecord::Migration[6.1]
  def up
    rename_column(:items, :date_found, :legacy_date_found)
    rename_column(:items, :found_at, :legacy_time_found)

    change_table :items do |t|
      t.column(:date_found, :date)
      t.column(:datetime_found, :datetime)
    end

    Item.reset_column_information
    Item.find_each do |item|
      date_found = (item.legacy_date_found || item.created_at).utc.to_date
      datetime_found = datetime_found(date_found, item.legacy_time_found)

      item.assign_attributes(date_found: date_found, datetime_found: datetime_found)
      item.save!(validate: false, touch: false)
    end
  end

  def down
    remove_columns(:items, :date_found, :datetime_found)
    rename_column(:items, :legacy_date_found, :date_found)
    rename_column(:items, :legacy_time_found, :found_at)
  end

  private

  def datetime_found(date_found, time_found)
    return unless date_found && time_found

    year, month, day = %i[year month day].map { |attr| date_found.send(attr) }

    # legacy time_found column stores literal Pacific time; Rails assumes it's
    # UTC and converts it to Pacific on load, so before we can extract the hour
    # we need to convert it back to 'UTC'
    time_found_utc = time_found.utc
    hour, min, sec = %i[hour min sec].map { |attr| time_found_utc.send(attr) }
    Time.zone.local(year, month, day, hour, min, sec)
  end
end
