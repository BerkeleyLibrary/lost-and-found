require 'capybara_helper'

describe 'admin user', type: :system do
  attr_reader :user

  before(:each) do
    @user = mock_login(:admin)
  end

  describe 'login' do
    it 'redirects to the item search page' do
      expect(page).to have_content('Search for lost items')
    end
  end

  describe 'admin home' do
    before(:each) do
      visit(admin_path)
    end

    it 'displays the admin page' do
      expected_links = [
        admin_users_path,
        admin_locations_path,
        admin_item_types_path,
        admin_purge_path,
        admin_claimed_path
      ]
      expected_links.each do |link|
        next if page.has_link?(href: link)
        expect(page).to have_link(href: link)
      end
    end

    describe 'add/edit users' do
      before(:each) do
        ensure_all_users!

        link = page.find_link(href: admin_users_path)
        link.click
      end

      it 'lists users' do
        User.find_each do |u|
          row = page.find('tr', text: u.uid)
          expect(row).to have_content(u.user_name)
          expect(row).to have_content(u.user_role) if u.user_role

          edit_path = edit_user_path(u.id)
          expect(row).to have_link(href: edit_path)

          toggle_status_path = toggle_user_status_path(u.id)
          toggle_status_link = row.find_link(href: toggle_status_path)
          expected_text = u.user_active ? 'Deactivate' : 'Activate'
          expect(toggle_status_link).to have_text(expected_text)
        end
      end

      it 'allows activating/deactivating users' do
        u = User.where.not(uid: user.uid).take
        expect(u.user_active).to eq(true) # just to be sure

        row = page.find('tr', text: u.uid)
        toggle_status_path = toggle_user_status_path(u.id)

        deactivate_link = row.find_link('Deactivate', href: toggle_status_path)

        # Deactivate, and wait for deactivation to take effect
        deactivate_link.click
        activate_link = page.find_link('Activate', href: toggle_status_path)

        u.reload
        expect(u.user_active).to eq(false)
        expect(u.updated_by).to eq(user.user_name)

        # Activate, and wait for activation to take effect
        activate_link.click
        expect(page).to have_link('Deactivate', href: toggle_status_path)

        u.reload
        expect(u.user_active).to eq(true)
      end

      it 'allows adding users' do
        uid = 5551211
        name = 'Paige J. Poe'
        role = 'Staff'

        fill_in('uid', with: uid)
        fill_in('user_name', with: name)
        select(role, from: 'user_role')

        # Add, and wait for add to complete
        page.click_link_or_button('Add user')
        row = page.find('tr', text: uid)

        u = User.find_by(uid: uid)
        expect(u.user_name).to eq(name)
        expect(u.user_role).to eq(role)
        expect(u.updated_by).to eq(user.user_name)

        expect(row).to have_content(u.user_name)
        expect(row).to have_content(u.user_role)

        edit_path = edit_user_path(u.id)
        expect(row).to have_link(href: edit_path)

        toggle_status_path = toggle_user_status_path(u.id)
        expect(row).to have_link('Deactivate', href: toggle_status_path)
      end

      it 'requires a name' do
        user_count = User.count

        uid = 5551211
        role = 'Staff'

        fill_in('uid', with: uid)
        select(role, from: 'user_role')
        page.click_link_or_button('Add user')

        # TODO: figure out how to test HTML5 native validation, or replace w/JS validation
        expect(page).not_to have_selector('tr', text: uid)

        expect(User.count).to eq(user_count)
      end

      it 'requires a UID' do
        user_count = User.count

        name = 'Paige J. Poe'
        role = 'Staff'

        fill_in('user_name', with: name)
        select(role, from: 'user_role')

        page.click_link_or_button('Add user')

        # TODO: figure out how to test HTML5 native validation, or replace w/JS validation
        expect(page).not_to have_selector('tr', text: name)

        expect(User.count).to eq(user_count)
      end

      it 'rejects non-numeric UIDs' do
        user_count = User.count

        name = 'Paige J. Poe'
        role = 'Staff'
        invalid_uid = 'not a valid UID'

        fill_in('user_name', with: name)
        fill_in('uid', with: invalid_uid)
        select(role, from: 'user_role')

        page.click_link_or_button('Add user')

        # TODO: figure out how to test HTML5 native validation, or replace w/JS validation
        expect(page).not_to have_selector('tr', text: name)

        expect(User.count).to eq(user_count)
      end

      it 'prevents adding duplicate UIDs' do
        user_count = User.count

        name = 'Paige J. Poe'
        role = 'Staff'

        fill_in('uid', with: user.uid)
        fill_in('user_name', with: name)
        select(role, from: 'user_role')

        page.click_link_or_button('Add user')
        expect(page).to have_content('already exists')
        expect(User.count).to eq(user_count)
      end

      it 'allows editing users' do
        u = User.where(user_role: 'Read-only').take
        expect(u.user_active).to eq(true) # just to be sure

        row = page.find('tr', text: u.uid)
        edit_path = edit_user_path(u.id)

        edit_link = row.find_link(href: edit_path)
        edit_link.click

        expect(page).to have_content('Edit user')

        role = 'Staff'
        uid = u.uid * 2
        name = u.user_name.sub(/[A-Z][a-z]+$/, 'Marumaru')

        fill_in('uid', with: uid)
        fill_in('user_name', with: name)
        select(role, from: 'user_role')
        find('#user_active').set(false)

        # Add, and wait for add to complete
        page.click_link_or_button('Update user')
        expect(page).to have_selector('tr', text: name)

        u.reload
        expect(u.user_name).to eq(name)
        expect(u.user_role).to eq(role)
        expect(u.uid).to eq(uid)
        expect(u.user_active).to eq(false)

        row = page.find('tr', text: u.uid)
        expect(row).to have_content(u.user_role)

        edit_path = edit_user_path(u.id)
        expect(row).to have_link(href: edit_path)

        toggle_status_path = toggle_user_status_path(u.id)
        expect(row).to have_link('Activate', href: toggle_status_path)
      end

      it 'prevents setting a duplicate UID' do
        u = User.where(user_role: 'Read-only').take

        old_uid = u.uid
        other_uid = user.uid
        expect(other_uid).not_to eq(old_uid) # just to be sure

        edit_path = edit_user_path(u.id)
        visit(edit_path)

        fill_in('uid', with: other_uid)
        page.click_link_or_button('Update user')

        expect(page).to have_content('already exists')

        u.reload
        expect(u.uid).to eq(old_uid)

        expect(User.where(uid: other_uid).count).to eq(1)
      end

      it 'prevents setting a non-numeric UID' do
        u = User.where(user_role: 'Read-only').take
        old_uid = u.uid

        edit_path = edit_user_path(u.id)
        visit(edit_path)

        invalid_uid = 'not a valid UID'
        fill_in('uid', with: invalid_uid)

        page.click_link_or_button('Update user')
        expect(page).to have_content('not numeric')

        u.reload
        expect(u.uid).to eq(old_uid)
      end
    end

    describe 'add/edit locations' do
      before(:each) do
        # TODO: enforce case-insensitive uniqueness w/o mangling user-entered names
        ['Doe', 'Moffitt', 'East Asian Library'].map { |loc| create(:location, location_name: loc.downcase) }
        visit(admin_locations_path)
      end

      it 'lists locations' do
        Location.find_each do |loc|
          titleized_name = loc.location_name.titleize
          row = page.find('tr', text: titleized_name)

          edit_path = edit_location_path(loc.id)
          expect(row).to have_link(href: edit_path)

          toggle_status_path = toggle_location_status_path(loc.id)
          toggle_status_link = row.find_link(href: toggle_status_path)
          expected_text = loc.location_active ? 'Deactivate' : 'Activate'
          expect(toggle_status_link).to have_text(expected_text)
        end
      end

      it 'allows activating/deactivating locations' do
        loc = Location.take
        expect(loc.location_active).to eq(true) # just to be sure

        titleized_name = loc.location_name.titleize

        row = page.find('tr', text: titleized_name)
        toggle_status_path = toggle_location_status_path(loc.id)

        deactivate_link = row.find_link('Deactivate', href: toggle_status_path)

        # Deactivate, and wait for deactivation to take effect
        deactivate_link.click
        activate_link = page.find_link('Activate', href: toggle_status_path)

        loc.reload
        expect(loc.location_active).to eq(false)
        expect(loc.updated_by).to eq(user.user_name)

        # Activate, and wait for activation to take effect
        activate_link.click
        expect(page).to have_link('Deactivate', href: toggle_status_path)

        loc.reload
        expect(loc.location_active).to eq(true)
      end

      it 'allows adding locations' do
        name = 'Gardner'

        fill_in('location_name', with: name)

        # Add, and wait for add to complete
        page.click_link_or_button('Add location')

        row = page.find('tr', text: name)

        downcased_name = name.downcase
        loc = Location.where('lower(location_name) = ?', downcased_name).take
        expect(loc.location_active).to eq(true)

        toggle_status_path = toggle_location_status_path(loc.id)
        expect(row).to have_link('Deactivate', href: toggle_status_path)
      end

      it 'requires a location name' do
        location_count = Location.count

        page.click_link_or_button('Add location')

        # TODO: figure out how to test HTML5 native validation, or replace w/JS validation
        rows = page.find_all('tr', text: 'Edit')
        expect(rows.size).to eq(location_count)
        expect(Location.count).to eq(location_count)
      end

      it 'prevents adding a duplicate location' do
        location_count = Location.count

        loc = Location.take

        titleized_name = loc.location_name.titleize
        fill_in('location_name', with: titleized_name)
        page.click_link_or_button('Add location')

        expect(page).to have_content('already exists')
        expect(page).to have_selector('tr', text: titleized_name, count: 1)
        expect(Location.count).to eq(location_count)

        downcased_name = loc.location_name.downcase
        fill_in('location_name', with: downcased_name)

        page.click_link_or_button('Add location')

        expect(page).to have_content('already exists')
        expect(page).to have_selector('tr', text: titleized_name, count: 1)
        expect(Location.count).to eq(location_count)
      end
    end

    describe 'add/edit item types' do
      before(:each) do
        # TODO: enforce case-insensitive uniqueness w/o mangling user-entered names
        ['Biro', 'Pencil', 'Trapper Keeper'].map { |t| create(:item_type, type_name: t.downcase, type_description: "a #{t.downcase}") }
        visit(admin_item_types_path)
      end

      it 'lists item_types' do
        ItemType.find_each do |t|
          titleized_name = t.type_name.titleize
          row = page.find('tr', text: titleized_name)

          edit_path = edit_item_type_path(t.id)
          expect(row).to have_link(href: edit_path)

          toggle_status_path = toggle_item_type_status_path(t.id)
          toggle_status_link = row.find_link(href: toggle_status_path)
          expected_text = t.type_active ? 'Deactivate' : 'Activate'
          expect(toggle_status_link).to have_text(expected_text)
        end
      end

      it 'allows activating/deactivating item_types' do
        t = ItemType.take
        expect(t.type_active).to eq(true) # just to be sure

        titleized_name = t.type_name.titleize

        row = page.find('tr', text: titleized_name)
        toggle_status_path = toggle_item_type_status_path(t.id)

        deactivate_link = row.find_link('Deactivate', href: toggle_status_path)

        # Deactivate, and wait for deactivation to take effect
        deactivate_link.click
        activate_link = page.find_link('Activate', href: toggle_status_path)

        t.reload
        expect(t.type_active).to eq(false)
        expect(t.updated_by).to eq(user.user_name)

        # Activate, and wait for activation to take effect
        activate_link.click
        expect(page).to have_link('Deactivate', href: toggle_status_path)

        t.reload
        expect(t.type_active).to eq(true)
      end

      it 'allows adding item_types' do
        name = 'Widget'

        fill_in('type_name', with: name)

        # Add, and wait for add to complete
        page.click_link_or_button('Add item type')

        row = page.find('tr', text: name)

        downcased_name = name.downcase
        t = ItemType.where('lower(type_name) = ?', downcased_name).take
        expect(t.type_active).to eq(true)

        toggle_status_path = toggle_item_type_status_path(t.id)
        expect(row).to have_link('Deactivate', href: toggle_status_path)
      end

      it 'requires a item_type name' do
        item_type_count = ItemType.count

        page.click_link_or_button('Add item type')

        # TODO: figure out how to test HTML5 native validation, or replace w/JS validation
        rows = page.find_all('tr', text: 'Edit')
        expect(rows.size).to eq(item_type_count)
        expect(ItemType.count).to eq(item_type_count)
      end

      it 'prevents adding a duplicate item_type' do
        item_type_count = ItemType.count

        t = ItemType.take

        titleized_name = t.type_name.titleize
        fill_in('type_name', with: titleized_name)
        page.click_link_or_button('Add item type')

        expect(page).to have_content('already exists')
        expect(page).to have_selector('tr', text: titleized_name, count: 1)
        expect(ItemType.count).to eq(item_type_count)

        downcased_name = t.type_name.downcase
        fill_in('type_name', with: downcased_name)

        page.click_link_or_button('Add item type')

        expect(page).to have_content('already exists')
        expect(page).to have_selector('tr', text: titleized_name, count: 1)
        expect(ItemType.count).to eq(item_type_count)
      end
    end

    describe 'item actions' do
      attr_reader :all_item_dates

      before(:each) do
        # TODO: enforce case-insensitive uniqueness w/o mangling user-entered names
        locations = ['Doe', 'Moffitt', 'East Asian Library'].map { |loc| create(:location, location_name: loc.downcase) }
        item_types = ['Pencil', 'Pen', 'Trapper Keeper'].map { |it| create(:item_type, type_name: it.downcase, type_description: "a #{it.downcase}") }
        locations.each_with_index do |loc, i|
          item_types.each_with_index do |type, j|
            create(
              :item,
              itemType: type.type_name,
              itemDescription: "description of #{type.type_name} found in #{loc.location_name}",
              image_path: File.join('spec/data/images', "#{type.type_name}.jpg"),
              itemDate: (Date.current - j.months - i.days),
              itemLocation: loc.location_name
            )
          end
        end

        @all_item_dates = Item.pluck(:itemDate).sort
      end

      describe 'view removed items' do
        before(:each) do
          Item.all.to_a.each_with_index do |item, i|
            next item.update!(claimedBy: 'Purged') if (i % 3) == 0
            next item.update!(claimedBy: "Claimer #{i}", itemStatus: 3) if i.even?
          end

          visit(admin_claimed_path)
        end

        it 'displays purged items' do
          table = page.find('#claimed_items_table')

          purged_items = Item.where(claimedBy: 'Purged')
          expect(purged_items.count).not_to eq(0) # just to be sure

          purged_items.find_each do |item|
            item_row = table.find('tr', text: item.itemDescription)

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

            expect(item_row).to have_content('Purged')
          end
        end

        it 'displays claimed items' do
          table = page.find('#claimed_items_table')

          claimed_items = Item.where('items."claimedBy" LIKE ?', 'Claimer %')
          expect(claimed_items.count).not_to eq(0) # just to be sure

          claimed_items.find_each do |item|
            item_row = table.find('tr', text: item.itemDescription)

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

            expect(item_row).to have_content(item.claimedBy)
          end
        end

        it 'does not display unclaimed items' do
          table = page.find('#claimed_items_table')

          unclaimed_items = Item.where(claimedBy: nil)
          expect(unclaimed_items.count).not_to eq(0) # just to be sure

          unclaimed_items.find_each do |item|
            expect(table).not_to have_content(item.itemDescription)
          end
        end
      end

      describe 'remove old items' do

        before(:each) do
          visit(admin_purge_path)
        end

        it 'purges items' do
          cutoff_date = all_item_dates[all_item_dates.size / 2]

          purged_ids = Item.where('items."itemDate" <= ?', cutoff_date).pluck(:id)
          unpurged_ids = Item.where('items."itemDate" > ?', cutoff_date).pluck(:id)

          fill_in('purgeTime', with: cutoff_date.strftime("%m/%d/%Y"))
          page.click_link_or_button('Purge items')

          expect(page).to have_content("#{purged_ids.size} items purged")

          actually_purged_ids = Item.where(claimedBy: 'Purged', itemUpdatedBy: user.user_name).pluck(:id)
          expect(actually_purged_ids).to contain_exactly(*purged_ids)

          actually_unpurged_ids = Item.where(claimedBy: nil).pluck(:id)
          expect(actually_unpurged_ids).to contain_exactly(*unpurged_ids)
        end

        it "doesn't mess with previously purged items" do
          cutoff_date_1 = all_item_dates[all_item_dates.size / 4]

          other_user_name = 'J. Other User'
          Item.where('items."itemDate" <= ?', cutoff_date_1).update_all(claimedBy: 'Purged', itemUpdatedBy: other_user_name)
          previously_purged_ids = Item.where(claimedBy: 'Purged').pluck(:id)

          cutoff_date_2 = all_item_dates[all_item_dates.size / 2]
          newly_purged_ids = Item.where('items."itemDate" <= ? AND items."itemDate" > ?', cutoff_date_2, cutoff_date_1).pluck(:id)

          fill_in('purgeTime', with: cutoff_date_2.strftime("%m/%d/%Y"))
          page.click_link_or_button('Purge items')

          expect(page).to have_content("#{newly_purged_ids.size} items purged")

          actually_purged_ids = Item.where(claimedBy: 'Purged', itemUpdatedBy: user.user_name).pluck(:id)
          expect(actually_purged_ids).to contain_exactly(*newly_purged_ids)

          all_purged_ids = Item.where(claimedBy: 'Purged').pluck(:id)
          expect(all_purged_ids).to contain_exactly(*(previously_purged_ids + newly_purged_ids))

          actually_previously_purged_ids = Item.where(claimedBy: 'Purged', itemUpdatedBy: other_user_name).pluck(:id)
          expect(actually_previously_purged_ids).to contain_exactly(*previously_purged_ids)
        end

        it "doesn't mess with previously claimed items" do
          # TODO: replace magic number with enum
          status_claimed = 3

          cutoff_date_1 = all_item_dates[all_item_dates.size / 4]
          other_user_name = 'J. Other User'
          Item.where('items."itemDate" <= ?', cutoff_date_1).update_all(claimedBy: 'Mr. Magoo', itemStatus: status_claimed, itemUpdatedBy: other_user_name)
          claimed_ids = Item.where(claimedBy: 'Mr. Magoo').pluck(:id)

          cutoff_date_2 = all_item_dates[all_item_dates.size / 2]
          newly_purged_ids = Item.where('items."itemDate" <= ? AND items."itemDate" > ?', cutoff_date_2, cutoff_date_1).pluck(:id)

          fill_in('purgeTime', with: cutoff_date_2.strftime("%m/%d/%Y"))
          page.click_link_or_button('Purge items')

          expect(page).to have_content("#{newly_purged_ids.size} items purged")

          actually_purged_ids = Item.where(claimedBy: 'Purged').pluck(:id)
          expect(actually_purged_ids).to contain_exactly(*newly_purged_ids)

          actually_claimed_ids = Item.where(claimedBy: 'Mr. Magoo', itemStatus: status_claimed).pluck(:id)
          expect(actually_claimed_ids).to contain_exactly(*claimed_ids)
        end
      end
    end

  end
end
