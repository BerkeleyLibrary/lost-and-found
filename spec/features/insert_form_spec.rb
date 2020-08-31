require 'rails_helper'

RSpec.describe 'Item insert tasks', type: :feature do
    before :each do
        page.set_rack_session(uid: "013191304")
        page.set_rack_session(user_role: "Staff")
        page.set_rack_session(user: "A user")
        page.set_rack_session(user_name: "Dante")
        page.set_rack_session(user_active: true)
    end

    scenario 'Insert panel accessible to staff level user' do
        visit '/insert_form'
        expect(page).to have_content('Add a lost item')
    end

    scenario 'Insert panel NOT accessible to read-only level user' do
      page.set_rack_session(user_role: "Read-only")
        visit '/insert_form'
        expect(page).to have_content('You must have staff level permission or greater to view this page')
    end

    scenario 'valid items inserted into database' do
        visit '/insert_form'
        fill_in "itemDescription", with: "TEST_ITEM"
        fill_in "whereFound", with: "TEST_LOCATION_DESCRIPTION"
        find('input[name="commit"]').click
        expect(page).to have_content('TEST_ITEM')
      end

      scenario 'Items missing required fields are NOT inserted into database' do
        page.set_rack_session(user_role: "Staff")
        visit '/insert_form'
        find('input[name="commit"]').click
        expect(page).to have_content('Item rejected. Missing required fields')
      end

      scenario 'Auto populates current user as itemUpdatedBy' do
        page.set_rack_session(user_role: "Staff")
        visit '/insert_form'
        expect(page).to have_content('Dante')
      end
end