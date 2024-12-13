require 'rails_helper'

describe ItemCsvImport, type: :model do
  let(:label) { "rspec-#{rand 100}" }
  let(:infile) { Rails.root.join('spec/fixtures/items.csv') }
  let(:outfile) { Rails.root.join("tmp/items-#{label}-out.csv") }
  let(:dupe_opts) do
    {
      id: 9002,
      description: 'Kate Spade gray',
      item_type: 'wallet',
      location: 'moffitt 4th fl entrance',
      date_found: Date.today,
      where_found: 'moffitt'
    }
  end

  subject do
    ItemCsvImport.new(
      label: label,
      cutoff_date: Date.today.to_s,
      infile: infile,
      outfile: outfile
    )
  end

  it 'should process a CSV' do
    subject.import!

    output = CSV.read(outfile, headers: true)
    expect(output.headers).to eq %w[
      status
      new_id
      original_id
      description
      item_type
      location
    ]
    expect(output.size).to eq(100)
    expect(output.by_col['status']).to eq(['created'] * 100)
  end

  it 'omits perfect duplicates from the output' do
    Item.create!(**dupe_opts, id: 9002)

    subject.import!

    output = CSV.read(outfile, headers: true)
    expect(output.size).to eq(99)
    expect(output.by_col['status']).to eq(['created'] * 99)
  end

  it 'skips already imported items' do
    subject.import!
    subject.import!

    output = CSV.read(outfile, headers: true)
    expect(output.by_col['status']).to eq(['skipped (duplicate)'] * 100)
  end

  it 'identifies duplicates with alternate IDs' do
    Item.create!(**dupe_opts, id: 90001)
    Item.create!(**dupe_opts, id: 90002)

    subject.import!

    output = CSV.read(outfile, headers: true)
    expect(output.size).to eq(100)
    expect(output.by_col['status']).to eq(['skipped (duplicate)'] + (['created'] * 99))

    duplicate = output.find { |row| row['original_id'] == '9002' && row['new_id'] == '90001,90002' }
    expect(duplicate).not_to be_nil
    expect(duplicate.to_h.symbolize_keys).to include(
      {
        original_id: '9002',
        new_id: '90001,90002',
        description: 'Kate Spade gray',
        item_type: 'wallet',
        location: 'moffitt 4th fl entrance'
      }
    )
  end
end
