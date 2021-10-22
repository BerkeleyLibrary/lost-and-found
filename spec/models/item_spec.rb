require 'rails_helper'

describe Item, type: :model do
  it 'Item should default to found' do
    item = Item.new()
    assert(1, item.itemStatus)
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
end
