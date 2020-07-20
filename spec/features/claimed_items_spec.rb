require 'rails_helper'

RSpec.describe 'Search form tasks', type: :feature do
    before :each do
        mock_omniauth_login "013191304"
        Capybara.current_session.driver.browser.set_cookie "user_role=Administrator"
        Capybara.current_session.driver.browser.set_cookie "user=a user"
        Capybara.current_session.driver.browser.set_cookie "user_name=Dante"
    end

    scenario 'Updated items are tracked in change history' do
        visit '/insert_form'
        fill_in 'itemDescription', with: "TEST_ITEM"
        fill_in "whereFound", with: "TEST LOCATION DESCRIPTION"
        find('input[name="commit"]').click
        click_link "Search"
        click_button "Submit"
        first('td').click_link('Edit')
        select "Found", :from => "itemStatus"
        p page.body
        expect(page).to have_selector('#claimedByLabel', visible: true)
      end
end