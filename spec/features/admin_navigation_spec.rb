require 'rails_helper'

RSpec.describe 'Navigate Admin tasks', type: :feature do
    before :each do
        mock_omniauth_login "013191304"
        Capybara.current_session.driver.browser.set_cookie "user_role=Administrator"
        Capybara.current_session.driver.browser.set_cookie "user=a user"
        Capybara.current_session.driver.browser.set_cookie "user_name=Dante"
    end

    scenario 'Admin panel accessible to Admin level user' do
        visit '/admin'
        click_link "Users Page"
        expect(page).to have_content('Active Users')
        visit '/admin'
        click_link "Locations Page"
        expect(page).to have_content('Active Locations')
        visit '/admin'
        click_link "Item Types Page"
        expect(page).to have_content('Active Item Types')
        visit '/admin'
        click_link "Items"
        expect(page).to have_content('Found Items')
    end
end