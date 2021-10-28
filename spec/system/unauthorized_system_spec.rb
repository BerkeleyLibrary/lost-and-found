require 'system_helper'

describe 'unauthorized CalNet user', type: :system do
  before(:each) do
    @user = mock_login(:other)
  end

  describe 'login' do
    it 'does not display the search page' do
      expect(page).to have_content('Forbidden')
      expect(page).not_to have_content('Search for lost items')
    end
  end

  context 'with data' do
    attr_reader :items

    before(:each) do
      @items = []

      # TODO: enforce case-insensitive uniqueness w/o mangling user-entered names
      locations = ['Doe', 'Moffitt', 'East Asian Library'].map { |loc| create(:location, location_name: loc.downcase) }
      item_types = ['Pencil', 'Pen', 'Trapper Keeper'].map { |it| create(:item_type, type_name: it.downcase, type_description: "a #{it.downcase}") }
      locations.each_with_index do |loc, i|
        item_types.each_with_index do |type, j|
          items << create(
            :item,
            itemType: type.type_name,
            itemDescription: "description of #{type.type_name} found in #{loc.location_name}",
            image_path: File.join('spec/data/images', "#{type.type_name}.jpg"),
            itemDate: (Date.current - j.months - (i + 1).days),
            itemLocation: loc.location_name
          )
        end
      end
    end

    context 'admin pages' do
      context 'admin pages' do
        it_behaves_like 'admin access is denied'
      end

      context 'staff pages' do
        it_behaves_like 'staff access is denied'
      end
    end
  end
end
