require 'rails_helper'

RSpec.describe 'Version history testing', type: :feature do
    before :each do
        mock_omniauth_login "013191304"
        page.set_rack_session(user_role: "Administrator")
        page.set_rack_session(user: "A user")
        page.set_rack_session(user_name: "Dante")
        page.set_rack_session(user_active: true)
    end

    with_versioning do
    #   scenario 'Items are given version history from Creation' do
    #   visit '/insert_form'
    #   fill_in "itemDescription", with: "TEST_ITEM"
    #   fill_in "itemFoundBy", with: "TEST_NAME"
    #   fill_in "whereFound", with: "TEST_LOCATION_DESCRIPTION"
    #   find('input[name="commit"]').click
    #   click_link "Search"
    #   click_button"Submit"
    #   first('td').click_link('History')
    #   expect(page).to have_content('Create')
    # end


    scenario 'Updated items are tracked in change history' do
      visit '/insert_form'
      fill_in 'itemDescription', with: "TEST_ITEM"
      fill_in "itemFoundBy", with: "TEST NAME"
      fill_in "whereFound", with: "TEST LOCATION DESCRIPTION"
      find('input[name="commit"]').click
      click_link "Search"
      click_button "Submit"
      first('td').click_link('Edit')
      fill_in 'itemDescription', with: "NEW_TEST_ITEM"
      find('input[name="commit"]').click
      click_link "Search"
      click_button "Submit"
      first('td').click_link('History')
      expect(page).to have_content('Update')
      expect(page).to have_content('TEST_ITEM to NEW_TEST_ITEM')
    end
  end
end