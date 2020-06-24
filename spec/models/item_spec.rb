require 'calnet_helper'

describe Item, type: :model do
  it 'Item should default to found' do
    item = Item.new()
    assert(1,item.itemStatus)
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

describe '`have_a_version_with` matcher' do
  before(:all) do
    class Item < ApplicationRecord
      has_paper_trail
    end
  end

  # it 'new items should have version history' do
  #   item = Item.new()
  #   item.itemDate =  Time.now
  #   item.itemFoundAt =  Time.now
  #   item.itemLocation = '?'
  #   item.itemType = '?'
  #   item.itemDescription= '?'
  #   item.itemLastModified=Time.now();
  #   item.itemStatus = 1;
  #   item.itemEnteredBy = "unknown";
  #   item.itemImage = "none";
  #   item.itemObsolete = 0;
  #   item.itemFoundBy =  'anonymous';
  #   item.libID = 115;
  #   item.created_at =Time.now();
  #   item.updated_at = Time.now();
  #   assert(1,item.itemStatus)
  #   item.save!
  #   p '-------------------'
  #   p item.versions
  #   expect(item).to have_a_version_with itemLocation: "?"
  #   item.update!(itemDescription: "The best")

  #   assert_select "p", "this is the test line"
  # end
end
