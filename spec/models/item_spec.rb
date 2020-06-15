require 'calnet_helper'

describe Item, type: :model do
  it 'Item should default to found' do
    item = Item.new()
    assert(1,item.itemStatus)
  end
end
