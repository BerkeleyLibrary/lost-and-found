require 'rails_helper'

describe Item, type: :model do
  it 'Item should default to found' do
    item = Item.create!(
      date_found: Date.current - 1.days,
      description: 'a description',
      datetime_found: Time.current,
      found_by: 'Testy McTestface',
      entered_by: 'Test',
      updated_by: 'Test',
      item_type: 'pen',
      location: 'the library',
      where_found: 'Somewhere'
    )
    expect(item.claimed).to eq(false)
    expect(item.purged).to eq(false)
  end

  it 'has a paper trail', versioning: true do
    expect(PaperTrail).to be_enabled

    item = Item.create!(
      date_found: Date.current - 1.days,
      description: 'a description',
      datetime_found: Time.current,
      found_by: 'Testy McTestface',
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

  context 'validation' do
    attr_reader :item

    before(:each) do
      @item = Item.create!(
        date_found: Date.current - 1.days,
        description: 'a description',
        datetime_found: Time.current,
        found_by: 'Testy McTestface',
        entered_by: 'Test',
        updated_by: 'Test',
        item_type: 'pen',
        location: 'the library',
        where_found: 'Somewhere'
      )
    end

    it 'disallows claiming an item without a claimer' do
      expect { item.update!(claimed: true) }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it 'disallows claiming an item with a blank claimer' do
      expect { item.update!(claimed: true, claimed_by: '   ') }.to raise_error(ActiveRecord::RecordInvalid)
    end

  end

  describe :by_keywords do
    it 'finds items by keywords' do
      keywords = %w[foo bar]
      expected_items = ['foo bar', 'bar foo corge', 'bar baz', 'foo baz', 'qux foo']
        .map { |desc| create(:item, description: desc, item_type: 'pen', location: 'the library') }
      unexpected_items = ['corge qux', 'qux baz', 'baz qux corge']
        .map { |desc| create(:item, description: desc, item_type: 'pen', location: 'the library') }

      results = Item.by_keywords(keywords)
      expect(results).to contain_exactly(*expected_items)

      unexpected_items.each { |item| expect(results).not_to include(item) }
    end
  end
end
