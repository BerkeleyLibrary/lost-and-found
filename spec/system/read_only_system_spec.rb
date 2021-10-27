require 'system_helper'

describe 'read-only user', type: :system do
  attr_reader :user

  before(:each) do
    @user = mock_login(:read_only)
  end

  after(:each) do
    logout!
  end

  describe 'login' do
    it 'redirects to the item search page' do
      expect(page).to have_content('Search for lost items')
    end

    it 'allows logout' do
      page.click_link_or_button('CalNet Logout')
      expect(page).to have_content('Logout Successful')
    end
  end

  describe 'session timeout' do
    it 'redirects to logout' do
      allow_any_instance_of(ApplicationController).to receive(:session_expired?).and_return(true)

      visit(search_form_path)
      expect(page).not_to have_content('Search for lost items')
      expect(page).to have_content('Logout Successful')
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
          item_date = (Date.current - j.months - (i + 1).days).to_date
          items << create(
            :item,
            itemType: type.type_name,
            itemDescription: "description of #{type.type_name} found in #{loc.location_name}",
            image_path: File.join('spec/data/images', "#{type.type_name}.jpg"),
            itemDate: item_date.to_time,
            itemLocation: loc.location_name
          )
        end
      end
    end

    describe 'search' do
      before(:each) do
        visit(search_form_path)
      end

      it 'finds all items' do
        page.click_link_or_button('Submit')
        expect(page).to have_content('Found Items')

        table = page.find('#found_items_table')

        Item.find_each do |item|
          item_rows = table.find_all('tr', text: item.itemDescription).to_a
          expect(item_rows.size).to eq(1)

          item_row = item_rows[0]

          view_path = item_path(item.id)
          expect(item_row).not_to have_link(href: view_path)

          edit_path = edit_item_path(item.id)
          expect(item_row).not_to have_link(href: edit_path)

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

      it 'finds items by location' do
        location = Location.take
        # TODO: enforce case-insensitive uniqueness w/o mangling user-entered names
        location_str = location.location_name.titleize
        select(location_str, from: 'itemLocation')

        page.click_link_or_button('Submit')
        expect(page).to have_content('Found Items')

        table = page.find('#found_items_table')

        Item.where(itemLocation: location.location_name).find_each do |item|
          expect(table).to have_selector('tr', text: item.itemDescription)
        end

        Item.where.not(itemLocation: location.location_name).find_each do |item|
          expect(table).not_to have_selector('tr', text: item.itemDescription)
        end
      end

      it 'finds items by type' do
        type = ItemType.take
        # TODO: enforce case-insensitive uniqueness w/o mangling user-entered names
        type_str = type.type_name.titleize
        select(type_str, from: 'itemType')

        page.click_link_or_button('Submit')
        expect(page).to have_content('Found Items')

        table = page.find('#found_items_table')

        Item.where(itemType: type.type_name).find_each do |item|
          expect(table).to have_selector('tr', text: item.itemDescription)
        end

        Item.where.not(itemType: type.type_name).find_each do |item|
          expect(table).not_to have_selector('tr', text: item.itemDescription)
        end
      end

      it 'finds items by date range' do
        all_item_dates = Item.pluck(:itemDate).sort
        date_start = all_item_dates[all_item_dates.size / 4]
        date_end = all_item_dates[all_item_dates.size / 2]

        fill_in('itemDate', with: date_start.strftime("%m/%d/%Y"))
        fill_in('itemDateEnd', with: date_end.strftime("%m/%d/%Y"))

        expected_ids = Item.where('items."itemDate" <= ? AND items."itemDate" >= ?', date_end, date_start).pluck(:id)

        page.click_link_or_button('Submit')
        expect(page).to have_content('Found Items')

        table = page.find('#found_items_table')

        aggregate_failures do
          items.each do |item|
            if expected_ids.include?(item.id)
              expect(table).to have_selector('tr', text: item.itemDescription), "Item not found; itemDate = #{item.itemDate} (range: #{date_start} - #{date_end})"
            else
              expect(table).not_to have_selector('tr', text: item.itemDescription), "Item found unexpectedly; itemDate = #{item.itemDate} (range: #{date_start} - #{date_end})"
            end
          end
        end
      end

      it 'finds items by exact date' do
        expected_item = items[items.size / 2]
        item_date = expected_item.itemDate

        fill_in('itemDate', with: item_date.strftime("%m/%d/%Y"))

        page.click_link_or_button('Submit')
        expect(page).to have_content('Found Items')

        table = page.find('#found_items_table')

        aggregate_failures do
          items.each do |item|
            if item == expected_item
              expect(table).to have_selector('tr', text: item.itemDescription)
            else
              expect(table).not_to have_selector('tr', text: item.itemDescription)
            end
          end
        end
      end

      it 'finds items by description' do
        even_items = []
        odd_items = []
        items.each_with_index do |item, i|
          (i.even? ? even_items : odd_items) << item
        end

        even_items.each_with_index { |item, i| item.update(itemDescription: "searchy test ##{i}") }

        page.fill_in('keyword', with: 'searchy')
        page.click_link_or_button('Submit')
        expect(page).to have_content('Found Items')

        table = page.find('#found_items_table')

        even_items.each do |item|
          expect(table).to have_selector('tr', text: item.itemDescription)
        end

        odd_items.each do |item|
          expect(table).not_to have_selector('tr', text: item.itemDescription)
        end
      end
    end

    context 'admin pages' do
      it_behaves_like 'admin access is denied'

      xit 'disallows viewing claimed or purged items' # TODO: implement this
    end

    context 'staff pages' do
      it 'disallows access to the add items page' do
        visit(insert_form_path)
        expect(page).not_to have_content('Add a lost item')
      end

      it 'disallows access to the edit item page' do
        item = items.last
        edit_path = edit_item_path(item.id)
        visit(edit_path)
        expect(page).not_to have_content('Edit item')
      end
    end
  end
end
