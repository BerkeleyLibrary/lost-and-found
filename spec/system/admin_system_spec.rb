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
          expect(row).to have_content(u.user_role)

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
    end

    describe 'add/edit locations' do
      before(:each) do
        # TODO: enforce case-insensitive uniqueness w/o mangling user-entered names
        #       - see https://stackoverflow.com/a/2223789/27358
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
  end

end
