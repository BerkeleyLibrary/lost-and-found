require 'capybara_helper'

describe 'admin user', type: :system do
  before(:each) do
    mock_login(:admin)
  end

  describe 'login' do
    it 'redirects to the item search page' do
      expect(page).to have_content('Search for lost items')
    end
  end

  context 'with data' do
    before(:each) do
      locations = ['Doe', 'Moffitt', 'East Asian Library'].map { |loc| create(:location, location_name: loc) }
      item_types = ['Pencil', 'Pen', 'Trapper Keeper'].map { |it| create(:item_type, type_name: it, type_description: "a #{it.downcase}") }
      locations.each do |loc|
        item_types.each do |type|
          create(
            :item,
            itemType: type.type_name,
            itemDescription: "description of #{loc} #{type}",
          )
        end
      end
    end
  end

  describe 'search' do
    context 'without items' do
      it 'allows search with no parameters' do
        page.click_link_or_button('Submit')
        expect(page).to have_content('Found Items')
      end
    end

    xcontext 'with items'
  end
end
