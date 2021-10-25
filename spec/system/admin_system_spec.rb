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
          user_row = page.find('tr', text: u.uid)
          expect(user_row).to have_content(u.user_name)
          expect(user_row).to have_content(u.user_role)

          edit_path = edit_user_path(u.id)
          expect(user_row).to have_link(href: edit_path)

          toggle_status_path = toggle_user_status_path(u.id)
          toggle_status_link = user_row.find_link(href: toggle_status_path)
          expected_text = u.user_active ? 'Deactivate' : 'Activate'
          expect(toggle_status_link).to have_text(expected_text)
        end
      end

      it 'allows activating/deactivating users' do
        u = User.where.not(uid: user.uid).take
        expect(u.user_active).to eq(true) # just to be sure

        user_row = page.find('tr', text: u.uid)
        toggle_status_path = toggle_user_status_path(u.id)

        deactivate_link = user_row.find_link('Deactivate', href: toggle_status_path)

        # Deactivate, and wait for deactivation to take effect
        deactivate_link.click
        activate_link = page.find_link('Activate', href: toggle_status_path)

        u.reload
        expect(u.user_active).to eq(false)

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
        user_row = page.find('tr', text: uid)

        u = User.find_by(uid: uid)
        expect(u.user_name).to eq(name)
        expect(u.user_role).to eq(role)

        expect(user_row).to have_content(u.user_name)
        expect(user_row).to have_content(u.user_role)

        edit_path = edit_user_path(u.id)
        expect(user_row).to have_link(href: edit_path)

        toggle_status_path = toggle_user_status_path(u.id)
        expect(user_row).to have_link('Deactivate', href: toggle_status_path)
      end

      it 'allows editing users' do
        u = User.where(user_role: 'Read-only').take
        expect(u.user_active).to eq(true) # just to be sure

        user_row = page.find('tr', text: u.uid)
        edit_path = edit_user_path(u.id)

        edit_link = user_row.find_link(href: edit_path)
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

        expect(user_row).to have_content(u.user_role)

        edit_path = edit_user_path(u.id)
        expect(user_row).to have_link(href: edit_path)

        toggle_status_path = toggle_user_status_path(u.id)
        expect(user_row).to have_link('Deactivate', href: toggle_status_path)
      end
    end
  end

end
