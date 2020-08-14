require 'rails_helper'

RSpec.describe 'Search form tasks', type: :feature do
    before :each do
        mock_omniauth_login "013191304"
        Capybara.current_session.driver.browser.set_cookie "user_role=Administrator"
        Capybara.current_session.driver.browser.set_cookie "user=a user"
        Capybara.current_session.driver.browser.set_cookie "user_name=Dante"
        Capybara.current_session.driver.browser.set_cookie "user_active=true"
    end

    scenario 'search form accessible to staff level user' do
      visit '/search_form'
      expect(page).to have_content('Search for lost items')
  end

  scenario 'Search form accessible to read-only level user' do
      Capybara.current_session.driver.browser.set_cookie "user_role=Read-only"
      visit '/search_form'
      expect(page).to have_content('Search for lost items')
  end

    scenario 'New items are visable in search all form' do
      visit '/insert_form'
      fill_in "itemDescription", with: "TEST_ITEM"
      find('input[name="commit"]').click
      click_link "Search"
      click_button "Submit"
      expect(page).to have_content('TEST_ITEM')
    end

    scenario 'Search form finds found items based on keywords' do
      visit '/insert_form'
      fill_in "itemDescription", with: "TEST_ITEM"
      find('input[name="commit"]').click
      click_link "Search"
      click_button "Submit"
      expect(page).to have_content('TEST_ITEM')
    end

    scenario 'Search form filters items based on keywords' do
      visit '/insert_form'
      fill_in "itemDescription", with: "HIDE ME"
      find('input[name="commit"]').click
      click_link "Search"
      fill_in "keyword", with:"TEST ITEM"
      find('input[name="commit"]').click
      expect(page).to have_no_content("HIDE ME")
    end

    scenario 'Search form filters against multiple keywords' do
      visit '/insert_form'
      fill_in "itemDescription", with: "A BLUE TEST ITEM"
      fill_in "whereFound", with: "A LOCATION DESCRIPTION"
      find('input[name="commit"]').click
      click_link "Search"
      fill_in "keyword", with:"BLUE BOAT ITEM"
      find('input[name="commit"]').click
      expect(page).to have_content("A BLUE TEST ITEM")
    end

    scenario 'Search form filter ignores case sensitivity' do
      visit '/insert_form'
      fill_in "itemDescription", with: "A blue TEST ITEM"
      find('input[name="commit"]').click
      click_link "Search"
      fill_in "keyword", with:"bLuE"
      find('input[name="commit"]').click
      expect(page).to have_content("A BLUE TEST ITEM")
    end

    scenario 'Home goes to search' do
      visit '/home'
      expect(page).to have_content("Search for lost items")
    end

end