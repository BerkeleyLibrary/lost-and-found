require 'rails_helper'

describe 'items/edit.html.erb', type: :view do
  before do
    location = create(:location, location_name: 'doe')
    type = create(:item_type, type_name: 'trapper keeper', type_description: 'A Trapper Keeper')
    assign :locations_layout, [%w[Doe doe]]
    assign :item_type_layout, [['Trapper Keeper', 'trapper keeper']]
    assign :item, create(:item, item_type: type.type_name, date_found: Date.today, location: location.location_name,
                                description: 'description', image_path: 'spec/data/images/Trapper Keeper.jpg')
    current_user = instance_double(User)
    allow(current_user).to receive(:user_name).and_return('awilfox')
    allow(view).to receive_messages(current_user:)
  end

  it 'renders without error' do
    render
    expect(rendered).to have_content 'Edit item'
  end

  context 'when an item is claimed' do
    before do
      view_assigns[:item].update(claimed: true, claimed_by: 'Anna Wilcox')
    end

    it 'requires entry in the claimed by field' do
      render
      assert_select 'input[name=?][class=required]', 'claimed_by'
    end
  end

  context 'when an item is unclaimed' do
    before do
      view_assigns[:item].update(claimed: false, claimed_by: nil)
    end

    it 'does not require entry in the claimed by field' do
      render
      assert_select 'input[name=?]', 'claimed_by'
      assert_select 'input[name=?][class=required]', 'claimed_by', count: 0
    end
  end
end
