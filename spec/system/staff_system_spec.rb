require 'capybara_helper'

describe 'admin user', type: :system do
  attr_reader :user

  before(:each) do
    @user = mock_login(:staff)
  end

  describe 'login' do
    it 'redirects to the item search page' do
      expect(page).to have_content('Search for lost items')
    end
  end

  context 'with data' do
    before(:each) do
      # TODO: enforce case-insensitive uniqueness w/o mangling user-entered names
      #       - see https://stackoverflow.com/a/2223789/27358
      locations = ['Doe', 'Moffitt', 'East Asian Library'].map { |loc| create(:location, location_name: loc.downcase) }
      item_types = ['Pencil', 'Pen', 'Trapper Keeper'].map { |it| create(:item_type, type_name: it.downcase, type_description: "a #{it.downcase}") }
      locations.each do |loc|
        item_types.each do |type|
          create(
            :item,
            itemType: type.type_name,
            itemDescription: "description of #{type.type_name} found in #{loc.location_name}",
            image_path: File.join('spec/data/images', "#{type.type_name}.jpg")
          )
        end
      end
    end

    describe 'search' do
      it 'finds the items' do
        page.click_link_or_button('Submit')
        expect(page).to have_content('Found Items')

        table = page.find('#found_items_table')

        Item.find_each do |item|
          item_rows = table.find_all('tr', text: item.itemDescription).to_a
          expect(item_rows.size).to eq(1)

          item_row = item_rows[0]

          view_path = item_path(item.id)
          expect(item_row).to have_link(href: view_path)

          edit_path = edit_item_path(item.id)
          expect(item_row).to have_link(href: edit_path)

          date_found = item.itemDate ? item.itemDate.strftime("%m/%d/%Y") : 'None'
          expect(item_row).to have_content(date_found)

          time_found = item.itemFoundAt ? item.itemFoundAt.strftime("%l:%M %P") : 'None'
          expect(item_row).to have_content(time_found)

          found_by = item.itemFoundBy || 'No one'
          expect(item_row).to have_content(found_by)

          location = item.itemLocation || 'None'
          expect(item_row).to have_content(location)

          where_found = item.whereFound || 'None'
          expect(item_row).to have_content(where_found)

          type = item.itemType || 'No type'
          expect(item_row).to have_content(type)
        end
      end
    end

    describe 'add item' do
      before(:each) do
        visit(insert_form_path)
      end

      it 'allows adding an item' do
        item_type = ItemType.take

        # TODO: enforce case-insensitive uniqueness w/o mangling user-entered names
        #       - see https://stackoverflow.com/a/2223789/27358
        item_type_name = item_type.type_name.capitalize

        description = 'unidentified object'
        location = Location.take

        # TODO: enforce case-insensitive uniqueness w/o mangling user-entered names
        #       - see https://stackoverflow.com/a/2223789/27358
        location_name = location.location_name.capitalize

        found_by = 'Mr. Magoo'
        where_found = 'New Jersey'

        when_found = Date.current
        item_date_str = when_found.strftime("%m/%d/%Y")

        img_path = 'spec/data/images/Object.jpg'
        img_basename = File.basename(img_path)

        select(item_type_name, from: 'itemType')
        fill_in('itemDescription', with: description)
        select(location_name, from: 'itemLocation')
        fill_in('itemFoundBy', with: found_by)
        fill_in('whereFound', with: where_found)
        fill_in('itemDate', with: item_date_str)
        # TODO: figure out how to test this
        # found_at_str = when_found.strftime("%l:%M %P")
        # fill_in('itemFoundAt', with: found_at_str)
        attach_file('image', img_path)

        page.click_link_or_button('Add item')

        expect(page).to have_content('item added')

        row = page.find('tr', text: description)

        [
          item_type_name,
          location_name,
          found_by,
          where_found,
          # TODO: figure out how to test this
          # found_at_str,
          item_date_str,
        ].each do |attr|
          attr_case_insentitive = /#{attr}/i
          expect(row).to have_content(attr_case_insentitive)
        end

        img = row.find('img')
        expect(img[:src]).to end_with(img_basename)

        item = Item.find_by(itemDescription: description)
        expect(item.itemLocation).to eq(location.location_name)
        expect(item.itemFoundBy).to eq(found_by)
        expect(item.whereFound).to eq(where_found)
        expect(item.itemDate.to_date).to eq(when_found.to_date)
      end

      xit 'requires a type'
      xit 'requires a location'
      xit 'requires a date'

      # TODO: anything else required?
    end
  end

  context 'without data' do
    describe 'search' do
      it 'allows search with no parameters' do
        page.click_link_or_button('Submit')
        expect(page).to have_content('Found Items')
      end
    end
  end
end
