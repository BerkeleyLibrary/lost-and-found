require 'rails_helper'

describe Item, type: :model do
  it 'Item should default to found' do
    # TODO: replace magic number with enum
    item = Item.new
    assert(1, item.itemStatus)
  end

  it 'has a paper trail', versioning: true do
    expect(PaperTrail).to be_enabled

    item = Item.create!(
      itemDate: Date.current - 1.days,
      itemDescription: 'a description',
      itemFoundAt: Time.current,
      itemFoundBy: 'Testy McTestface',
      itemStatus: 1, # TODO: replace magic number with enum
      itemEnteredBy: 'Test',
      itemUpdatedBy: 'Test',
      whereFound: 'Somewhere',
    )
    expect(item.versions.size).to eq(1)

    item.update(whereFound: 'Somewhere else')
    expect(item.versions.size).to eq(2)
  end
end
