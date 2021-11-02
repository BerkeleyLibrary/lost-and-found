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
          date_found = (Date.current - j.months - (i + 1).days).to_date
          items << create(
            :item,
            item_type: type.type_name,
            description: "description of #{type.type_name} found in #{loc.location_name}",
            image_path: File.join('spec/data/images', "#{type.type_name.titleize}.jpg"),
            date_found: date_found,
            location: loc.location_name
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
          item_rows = table.find_all('tr', text: item.description).to_a
          expect(item_rows.size).to eq(1)

          item_row = item_rows[0]

          view_path = item_path(item.id)
          expect(item_row).not_to have_link(href: view_path)

          edit_path = edit_item_path(item.id)
          expect(item_row).not_to have_link(href: edit_path)

          date_found = item.date_found ? item.date_found.strftime('%m/%d/%Y') : 'None'
          expect(item_row).to have_content(date_found)

          time_found = item.datetime_found ? item.datetime_found.strftime('%l:%M %P') : 'None'
          expect(item_row).to have_content(time_found)

          found_by = item.found_by || 'No one'
          expect(item_row).to have_content(found_by)

          location = item.location || 'None'
          expect(item_row).to have_content(location)

          where_found = item.where_found || 'None'
          expect(item_row).to have_content(where_found)

          type = item.item_type || 'No type'
          expect(item_row).to have_content(type)
        end
      end

      it 'finds items by location' do
        location = Location.take
        # TODO: enforce case-insensitive uniqueness w/o mangling user-entered names
        location_str = location.location_name.titleize
        select(location_str, from: 'location')

        page.click_link_or_button('Submit')
        expect(page).to have_content('Found Items')

        table = page.find('#found_items_table')

        Item.where(location: location.location_name).find_each do |item|
          expect(table).to have_selector('tr', text: item.description)
        end

        Item.where.not(location: location.location_name).find_each do |item|
          expect(table).not_to have_selector('tr', text: item.description)
        end
      end

      it 'finds items by type' do
        type = ItemType.take
        # TODO: enforce case-insensitive uniqueness w/o mangling user-entered names
        type_str = type.type_name.titleize
        select(type_str, from: 'item_type')

        page.click_link_or_button('Submit')
        expect(page).to have_content('Found Items')

        table = page.find('#found_items_table')

        Item.where(item_type: type.type_name).find_each do |item|
          expect(table).to have_selector('tr', text: item.description)
        end

        Item.where.not(item_type: type.type_name).find_each do |item|
          expect(table).not_to have_selector('tr', text: item.description)
        end
      end

      it 'finds items by date range' do
        all_date_founds = Item.pluck(:date_found).sort
        date_start = all_date_founds[all_date_founds.size / 4]
        date_end = all_date_founds[all_date_founds.size / 2]

        fill_in('date_found', with: date_start.strftime('%m/%d/%Y'))
        fill_in('date_foundEnd', with: date_end.strftime('%m/%d/%Y'))

        expected_ids = Item.where('items."date_found" <= ? AND items."date_found" >= ?', date_end, date_start).pluck(:id)

        page.click_link_or_button('Submit')
        expect(page).to have_content('Found Items')

        table = page.find('#found_items_table')

        aggregate_failures do
          items.each do |item|
            if expected_ids.include?(item.id)
              expect(table).to have_selector('tr', text: item.description),
                               "Item not found; date_found = #{item.date_found} (range: #{date_start} - #{date_end})"
            else
              expect(table).not_to have_selector('tr', text: item.description),
                                   "Item found unexpectedly; date_found = #{item.date_found} (range: #{date_start} - #{date_end})"
            end
          end
        end
      end

      it 'finds items by exact date' do
        expected_item = items[items.size / 2]
        date_found = expected_item.date_found

        fill_in('date_found', with: date_found.strftime('%m/%d/%Y'))

        page.click_link_or_button('Submit')
        expect(page).to have_content('Found Items')

        table = page.find('#found_items_table')

        aggregate_failures do
          items.each do |item|
            if item == expected_item
              expect(table).to have_selector('tr', text: item.description)
            else
              expect(table).not_to have_selector('tr', text: item.description)
            end
          end
        end
      end

      it 'finds items by description' do
        unexpected = []
        expected = []
        items.each_with_index do |item, i|
          if (i % 3) == 0
            item.update(description: "searchy texty #{i}")
          elsif (i % 4) == 0
            item.update(description: "texty #{i}")
          elsif i.even?
            item.update(description: "searchy #{i}")
          else
            unexpected << item
            next
          end
          expected << item
        end

        page.fill_in('keyword', with: 'texty searchy')
        page.click_link_or_button('Submit')
        expect(page).to have_content('Found Items')

        table = page.find('#found_items_table')

        expected.each do |item|
          expect(table).to have_selector('tr', text: item.description)
        end

        unexpected.each do |item|
          expect(table).not_to have_selector('tr', text: item.description)
        end
      end
    end

    context 'admin pages' do
      it_behaves_like 'admin access is denied'
    end

    context 'staff pages' do
      it_behaves_like 'staff access is denied'
    end
  end

  context 'pagination' do
    attr_reader :locations, :item_types

    before(:each) do
      @locations = ['Doe', 'Moffitt', 'East Asian Library'].map { |loc| create(:location, location_name: loc.downcase) }
      @item_types = ['Pencil', 'Pen', 'Trapper Keeper'].map { |it| create(:item_type, type_name: it.downcase, type_description: "a #{it.downcase}") }

      visit(search_form_path)
    end

    it 'paginates the default search results' do
      page_size = Kaminari.config.default_per_page
      expect(page_size).not_to be_nil # just to be sure

      items = Array.new(2 * page_size + 1) do |i|
        loc = locations[i % locations.size]
        type = item_types[i % item_types.size]

        start_date = Date.current

        create(
          :item,
          item_type: type.type_name,
          description: "item #{i} desc",
          date_found: start_date,
          datetime_found: start_date + i.seconds,
          location: loc.location_name
        )
      end
      expect(Item.count).to eq(items.size) # just to be sure

      ordered_items = Item.order('date_found DESC', 'datetime_found DESC NULLS LAST', 'created_at DESC')
      items.sort! do |i1, i2|
        df1 = i1.date_found
        df2 = i2.date_found
        o = df2 <=> df1                 # NOTE: reverse order
        next o if o != 0

        dt1 = i1.datetime_found || Time.new(0)
        dt2 = i2.datetime_found || Time.new(0)
        o = dt2 <=> dt1                 # NOTE: reverse order
        next o if o != 0

        i2.created_at <=> i1.created_at # NOTE: reverse order
      end

      expected_page_1 = items[0...page_size]
      expect(expected_page_1).not_to be_empty # just to be sure
      expect(ordered_items.page(1)).to contain_exactly(*expected_page_1)

      expected_page_2 = items[page_size...(2 * page_size)]
      expect(expected_page_2).not_to be_empty # just to be sure
      expect(ordered_items.page(2)).to contain_exactly(*expected_page_2)

      expected_page_3 = items[(2 * page_size)...]
      expect(expected_page_3).not_to be_empty # just to be sure
      expect(ordered_items.page(3)).to contain_exactly(*expected_page_3)

      page.click_link_or_button('Submit')
      expect(page).to have_content('Found Items')

      table = page.find('#found_items_table')
      expected_page_1.each { |item| expect(table).to have_selector('tr', text: item.description) }
      expected_page_2.each { |item| expect(table).not_to have_selector('tr', text: item.description) }
      expected_page_3.each { |item| expect(table).not_to have_selector('tr', text: item.description) }

      # click "Next" and wait for page to load
      page.click_link(nil, text: /next/i)
      expect(page).to have_link(nil, text: /first/i)

      expected_page_1.each { |item| expect(table).not_to have_selector('tr', text: item.description) }
      expected_page_2.each { |item| expect(table).to have_selector('tr', text: item.description) }
      expected_page_3.each { |item| expect(table).not_to have_selector('tr', text: item.description) }

      # click "Next" and wait for page to load
      page.click_link(nil, text: /last/i)
      expect(page).not_to have_link(nil, text: /last/i)

      expected_page_1.each { |item| expect(table).not_to have_selector('tr', text: item.description) }
      expected_page_2.each { |item| expect(table).not_to have_selector('tr', text: item.description) }
      expected_page_3.each { |item| expect(table).to have_selector('tr', text: item.description) }
    end
  end
end
