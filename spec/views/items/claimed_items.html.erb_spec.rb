require 'rails_helper'

describe 'items/claimed_items.html.erb', type: :view do
  context 'without data' do
    before do
      assign :items_claimed, Kaminari.paginate_array([]).page(1)
    end

    it 'renders without error' do
      render
      expect(rendered).to have_content 'Claimed items'
    end

    it 'renders no item rows' do
      render
      expect(rendered).not_to have_selector 'tbody>tr'
    end
  end

  context 'with items' do
    before do
      location = create(:location, location_name: 'doe')
      type = create(:item_type, type_name: 'trapper keeper', type_description: 'A Trapper Keeper')
      items = [
        create(:item, item_type: type.type_name, date_found: Date.today, location: location.location_name,
               description: 'description', claimed: true, claimed_by: 'Lisa Weber',
               image_path: File.join('spec/data/images', "#{type.type_name.titleize}.jpg")),
        create(:item, item_type: type.type_name, date_found: Date.yesterday, location: location.location_name,
               description: 'a Trapper Keeper found in Doe', claimed: true, claimed_by: 'Anna Wilcox'),
        create(:item, item_type: type.type_name, date_found: Date.today, location: location.location_name,
               description: 'description', purged: true,
               image_path: File.join('spec/data/images', "#{type.type_name.titleize}.jpg")),
      ]
      assign :items_claimed, Kaminari.paginate_array(items).page(1)
      current_user = instance_double(User)
      allow(current_user).to receive(:staff_or_admin?).and_return(false)
      allow(view).to receive_messages(current_user:)
    end

    it 'renders without error' do
      render
      expect(rendered).to have_content 'Claimed items'
    end

    it 'renders item rows for each item claimed' do
      render
      expect(rendered).to have_selector 'tbody>tr', count: 3
    end

    it 'shows who claimed each item' do
      render
      expect(rendered).to have_content 'Lisa Weber'
      expect(rendered).to have_content 'Anna Wilcox'
    end

    it 'shows when an item is purged' do
      render
      expect(rendered).to have_content 'Purged', count: 1
    end

    it 'notates when an image is missing' do
      render
      expect(rendered).to have_selector 'img', count: 2
      expect(rendered).to have_content 'No image', count: 1
    end
  end
end