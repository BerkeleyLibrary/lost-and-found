require 'system_helper'

describe 'staff user', type: :system do
  attr_reader :user

  before(:each) do
    @user = mock_login(:staff)
  end

  after(:each) do
    logout!
  end

  describe 'login' do
    it 'redirects to the item search page' do
      expect(page).to have_content('Search for lost items')
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

    context 'items' do

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

            date_found = item.itemDate ? item.itemDate.strftime('%m/%d/%Y') : 'None'
            expect(item_row).to have_content(date_found)

            time_found = item.itemFoundAt ? item.itemFoundAt.strftime('%l:%M %P') : 'None'
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

        let(:description) { 'unidentified object' }
        let(:found_by) { 'Mr. Magoo' }
        let(:where_found) { 'New Jersey' }
        let(:img_path) { 'spec/data/images/Object.jpg' }

        attr_reader :item_type
        attr_reader :item_type_name
        attr_reader :location
        attr_reader :location_name
        attr_reader :when_found
        attr_reader :item_date_str

        before(:each) do
          visit(insert_form_path)

          @item_type = ItemType.take
          @location = Location.take
          @when_found = Date.current - 1
          @item_date_str = when_found.strftime('%m/%d/%Y')

          # TODO: enforce case-insensitive uniqueness w/o mangling user-entered names
          @item_type_name = item_type.type_name.capitalize

          # TODO: enforce case-insensitive uniqueness w/o mangling user-entered names
          @location_name = location.location_name.capitalize
        end

        it 'allows adding an item' do
          select(location_name, from: 'itemLocation')
          fill_in('itemFoundBy', with: found_by)
          fill_in('itemDescription', with: description)
          fill_in('whereFound', with: where_found)
          select(item_type_name, from: 'itemType')
          fill_in('itemDate', with: item_date_str)
          # TODO: figure out how to test time widget
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
            item_date_str
          ].each do |attr|
            attr_case_insentitive = /#{attr}/i
            expect(row).to have_content(attr_case_insentitive)
          end

          img = row.find('img')
          img_basename = File.basename(img_path)
          expect(img[:src]).to end_with(img_basename)

          item = Item.find_by(itemDescription: description)
          expect(item.itemType).to eq(item_type.type_name)
          expect(item.itemLocation).to eq(location.location_name)
          expect(item.itemFoundBy).to eq(found_by)
          expect(item.whereFound).to eq(where_found)
          expect(item.itemDate.to_date).to eq(when_found.to_date)
        end

        it 'requires a description' do
          select(location_name, from: 'itemLocation')
          fill_in('itemFoundBy', with: found_by)
          fill_in('whereFound', with: where_found)
          select(item_type_name, from: 'itemType')
          fill_in('itemDate', with: item_date_str)
          attach_file('image', img_path)

          page.click_link_or_button('Add item')
          expect(page).not_to have_content('item added')
        end

        it 'requires a type' do
          select(location_name, from: 'itemLocation')
          fill_in('itemFoundBy', with: found_by)
          fill_in('itemDescription', with: description)
          fill_in('whereFound', with: where_found)
          fill_in('itemDate', with: item_date_str)
          attach_file('image', img_path)

          page.click_link_or_button('Add item')
          expect(page).not_to have_content('item added')
        end

        it 'requires a location' do
          fill_in('itemFoundBy', with: found_by)
          fill_in('itemDescription', with: description)
          fill_in('whereFound', with: where_found)
          select(item_type_name, from: 'itemType')
          fill_in('itemDate', with: item_date_str)
          attach_file('image', img_path)

          page.click_link_or_button('Add item')
          expect(page).not_to have_content('item added')
        end

        it 'requires a date found' do
          select(location_name, from: 'itemLocation')
          fill_in('itemFoundBy', with: found_by)
          fill_in('itemDescription', with: description)
          fill_in('whereFound', with: where_found)
          select(item_type_name, from: 'itemType')
          attach_file('image', img_path)

          page.click_link_or_button('Add item')
          expect(page).not_to have_content('item added')
        end

        it 'requires a place found' do
          select(location_name, from: 'itemLocation')
          fill_in('itemFoundBy', with: found_by)
          fill_in('itemDescription', with: description)
          select(item_type_name, from: 'itemType')
          fill_in('itemDate', with: item_date_str)
          attach_file('image', img_path)

          page.click_link_or_button('Add item')
          expect(page).not_to have_content('item added')
        end
      end

      describe 'edit item' do
        attr_reader :item
        attr_reader :edit_path

        before(:each) do
          @item = items.last

          @edit_path = edit_item_path(item.id)
          visit(edit_path)
        end

        it 'allows editing an item' do
          # TODO: enforce case-insensitive uniqueness w/o mangling user-entered names
          new_location = Location.where('LOWER(location_name) <> ?', item.itemLocation.downcase).take
          new_location_str = new_location.location_name.titleize

          new_found_by = 'Mr. Magoo'

          new_description = 'the new description'

          # TODO: enforce case-insensitive uniqueness w/o mangling user-entered names
          new_type = ItemType.where('LOWER(type_name) <> ?', item.itemType.downcase).take
          new_type_str = new_type.type_name.titleize

          new_where_found = 'Pennsylvania'

          new_when_found = item.itemDate - 1.days
          new_when_found_str = new_when_found.strftime('%m/%d/%Y')

          select(new_location_str, from: 'itemLocation')
          fill_in('itemFoundBy', with: new_found_by, fill_options: { clear: :backspace })
          fill_in('itemDescription', with: new_description, fill_options: { clear: :backspace })
          fill_in('whereFound', with: new_where_found, fill_options: { clear: :backspace })
          select(new_type_str, from: 'itemType')
          fill_in('itemDate', with: new_when_found_str, fill_options: { clear: :backspace })

          new_img_path = 'spec/data/images/Object.jpg'
          attach_file('image', new_img_path)

          page.click_link_or_button('Update item')
          expect(page).to have_content('item updated')

          item.reload
          expect(item.itemDescription).to eq(new_description)
          expect(item.itemLocation).to eq(new_location.location_name)
          expect(item.itemFoundBy).to eq(new_found_by)
          expect(item.whereFound).to eq(new_where_found)
          expect(item.itemDate.to_date).to eq(new_when_found.to_date)
          expect(item.itemUpdatedBy).to eq(user.user_name)
        end

        it 'allows adding an image to an item with no image' do
          image_blob = item.image
          item.update!(image: nil, image_url: nil)
          image_blob.purge

          visit(edit_path)
          new_img_path = 'spec/data/images/Object.jpg'
          attach_file('image', new_img_path)

          page.click_link_or_button('Update item')
          expect(page).to have_content('item updated')

          item.reload
          expect(item.image_url).to end_with(File.basename(new_img_path))
        end

        it 'allows claiming an item' do
          # TODO: replace magic number with enum
          status_claimed = 3
          claimed_by = 'Mr. Magoo'

          select('Claimed', from: 'itemStatus')
          fill_in('claimedBy', with: claimed_by)

          page.click_link_or_button('Update item')

          expect(page).to have_content('item updated')

          item.reload
          expect(item.itemStatus).to eq(status_claimed)
          expect(item.claimedBy).to eq(claimed_by)
        end
      end

      describe 'history', versioning: true do
        attr_reader :item
        attr_reader :show_path

        before(:each) do
          @item = items.last
          @show_path = item_path(item.id)
        end

        it 'shows the creation of an item' do
          visit(show_path)

          row = page.find('tr', text: 'Create')

          item_date_str = item.itemDate.strftime('%m/%d/%Y')
          expect(row).to have_content(item_date_str)
          found_at_str = item.itemFoundAt.strftime('%l:%M %P')
          expect(row).to have_content(found_at_str)
          expect(row).to have_content(item.itemFoundBy)
          expect(row).to have_content(item.itemEnteredBy)
          expect(row).to have_content(item.itemUpdatedBy)
          expect(row).to have_content(item.whereFound)

          expect(item.versions.size).to eq(1)
        end

        it 'shows edits' do
          edit_path = edit_item_path(item.id)
          visit(edit_path)

          new_description = 'this is the new description'
          claimed_by = 'Mr. Magoo'

          select('Claimed', from: 'itemStatus')
          fill_in('itemDescription', with: new_description, fill_options: { clear: :backspace })
          fill_in('claimedBy', with: claimed_by)

          page.click_link_or_button('Update item')
          expect(page).to have_content('item updated')

          visit(show_path)

          row = page.find('tr', text: new_description)
          expect(row).to have_content('Update')
          expect(row).to have_content(user.user_name)
          expect(row).to have_content(claimed_by)

          item.reload
          expect(item.versions.size).to eq(2)
        end
      end

    end

    context 'admin pages' do
      it_behaves_like 'admin access is denied'

      it 'allows viewing claimed items, but not purged items' do
        Item.all.to_a.each_with_index do |item, i|
          next item.update!(claimedBy: 'Purged') if (i % 3) == 0
          next item.update!(claimedBy: "Claimer #{i}", itemStatus: 3) if i.even?
        end

        visit(admin_claimed_path)

        table = page.find('#claimed_items_table')

        purged_items = Item.where(claimedBy: 'Purged')
        expect(purged_items.count).not_to eq(0) # just to be sure
        purged_items.find_each do |item|
          expect(table).not_to have_selector('tr', text: item.itemDescription)
        end

        claimed_items = Item.where('items."claimedBy" LIKE ?', 'Claimer %')
        expect(claimed_items.count).not_to eq(0) # just to be sure

        claimed_items.find_each do |item|
          expect(table).to have_selector('tr', text: item.itemDescription)
        end
      end
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
