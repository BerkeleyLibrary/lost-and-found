require 'rails_helper'

describe Item, type: :model do
  it 'Item should default to found' do
    # TODO: replace magic number with enum
    item = Item.new
    assert(1, item.status)
  end

  it 'has a paper trail', versioning: true do
    expect(PaperTrail).to be_enabled

    item = Item.create!(
      date_found: Date.current - 1.days,
      description: 'a description',
      found_at: Time.current,
      found_by: 'Testy McTestface',
      status: 1, # TODO: replace magic number with enum
      entered_by: 'Test',
      updated_by: 'Test',
      item_type: 'pen',
      location: 'the library',
      where_found: 'Somewhere'
    )
    expect(item.versions.size).to eq(1)

    item.update(where_found: 'Somewhere else')
    expect(item.versions.size).to eq(2)
  end
end
