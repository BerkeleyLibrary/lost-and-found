require 'calnet_helper'

describe Item, type: :model do
  it 'Item should default to found' do
    item = Item.new()
    assert(1,item.itemStatus)
  end

  it 'new items should have version history for there creation' do
    item = Item.create()
    assert(1,item.itemStatus)
    assert(item.versions)
    p '----------------'
    p item.versions[0];
  end

  describe 'add versioning to the `item` class' do
    before(:all) do
      class Item < ApplicationRecord
        has_paper_trail
      end
    end

    it 'enables paper trail' do
      is_expected.to be_versioned
    end
  end

end
