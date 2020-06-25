require 'rails_helper'

RSpec.describe 'Item insert tasks', type: :feature do
    before :each do
        mock_omniauth_login "013191304"
        Capybara.current_session.driver.browser.set_cookie "user_role=Staff"
        Capybara.current_session.driver.browser.set_cookie "user=a user"
        Capybara.current_session.driver.browser.set_cookie "user_name=Dante"
    end

    scenario 'Insert panel accessible to staff level user' do
        visit '/insert_form'
        expect(page).to have_content('Add a lost item')
    end

    scenario 'Insert panel NOT accessible to read-only level user' do
        Capybara.current_session.driver.browser.set_cookie "user_role=Read-only"
        visit '/insert_form'
        expect(page).to have_content('You must have staff level permission or greater to view this page')
    end

    scenario 'valid items inserted into database' do
        visit '/insert_form'
        fill_in "itemDescription", with: "TEST_ITEM"
        find('input[name="commit"]').click
        expect(page).to have_content('TEST_ITEM')
      end

      scenario 'Items missing required fields are NOT inserted into database' do
        Capybara.current_session.driver.browser.set_cookie "user_role=Staff"
        visit '/insert_form'
        find('input[name="commit"]').click
        expect(page).to have_content('Item rejected. Missing required fields')
      end

      scenario 'Auto populates current user as itemUpdatedBy' do
        Capybara.current_session.driver.browser.set_cookie "user_role=Staff"
        visit '/insert_form'
        expect(page).to have_content('Dante')
        # find('input[name="commit"]').click
      end
end