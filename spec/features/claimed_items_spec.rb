require 'rails_helper'

RSpec.describe 'Search form tasks', type: :feature do
    before :each do
        mock_omniauth_login "013191304"
        Capybara.current_session.driver.browser.set_cookie "user_role=Administrator"
        Capybara.current_session.driver.browser.set_cookie "user=a user"
        Capybara.current_session.driver.browser.set_cookie "user_name=Dante"
    end

    scenario 'Setting item to claimed reveals Found By field' do
        visit '/insert_form'
        fill_in 'itemDescription', with: "TEST_ITEM"
        find('input[name="commit"]').click
        click_link "Search"
        click_link "Show all found items"
        first('td').click_link('Edit')
        within '#itemStatus' do
            find("option[value='1\']").click
        end

        p '============='
        p page.body
        p '============='
        find('#claimedByLabel').should_not be_visible
        within '#itemStatus' do
            find("option[value='3\]").click
          end
          p '==========='
          p page.body
          p '==========='
        expect(page).to have_selector('#claimedByLabel', visible: true) 
    end
end