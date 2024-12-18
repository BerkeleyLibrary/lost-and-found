require 'csv'

class ItemCsvImport
  STATUS_CREATED = 'created'.freeze
  STATUS_DUPLICATE = 'skipped (duplicate)'.freeze

  attr_accessor :infile, :outfile, :label, :cutoff_date

  def initialize(label:, cutoff_date:, infile: nil, outfile: nil)
    raise ArgumentError, '`label` is required' if label.empty?
    @label = label

    raise ArgumentError, '`cutoff_date` is required' if cutoff_date.empty?
    @cutoff_date = Date.parse(cutoff_date)

    @infile = infile || Rails.root.join('tmp', 'items.csv')
    @outfile = outfile || Rails.root.join('tmp', "#{infile.basename('.csv')}-processed.csv")
  end

  # rubocop:disable Metrics/AbcSize
  def import!
    CSV.open(outfile, 'wb') do |table_out|
      table_out << %w[status new_id original_id description item_type location]

      CSV.open(infile, headers: true, header_converters: :symbol, converters: :numeric) do |table_in|
        table_in.each do |row|
          if (dupes = similar_items(row)).any?
            dupe_ids = dupes.pluck(:id)
            add_row(table_out, STATUS_DUPLICATE, dupe_ids.join(','), row) \
              if dupe_ids.none? { |id| id == row[:id] }
            next
          end

          item = create_item! row
          add_row(table_out, STATUS_CREATED, item.id, row)
        end
      end
    end
  end
  # rubocop:enable Metrics/AbcSize

  private

  def add_row(table, status, new_id, row)
    table << [status, new_id, *row.fields(*%i[id description item_type location])]
  end

  def create_item!(row)
    Item.create!(
      **row.to_h.except(:id, :description),
      description: augmented_description(row)
    )
  end

  def augmented_description(row)
    "#{row[:description].strip} (#{label}; OldID=#{row[:id]})"
  end

  def similar_items(row)
    matches_exactly = {
      created_at: cutoff_date..,
      description: row[:description],
      item_type: row[:item_type],
      location: row[:location]
    }
    previously_imported = 'description LIKE ?', "%OldID=#{row[:id]}%"

    Item
      .where(matches_exactly)
      .or(Item.where(previously_imported))
      .order('id ASC')
  end
end
