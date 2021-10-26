require 'rails_helper'

RSpec.describe 'Search form tasks', type: :feature do
  before :each do
    page.set_rack_session(uid: "013191304")
    page.set_rack_session(user_role: "Administrator")
    page.set_rack_session(user: "A user")
    page.set_rack_session(user_name: "Dante")
    page.set_rack_session(user_active: true)

    visit '/admin'
    click_link 'Item Types'
    fill_in 'type_name', with: "Test_type"
    find('input[name="commit"]').click
    visit '/admin'
    click_link 'Locations'
    fill_in 'location_name', with: "Test Location"
    find('input[name="commit"]').click
  end

  scenario 'search form accessible to staff level user' do
    visit '/search_form'
    expect(page).to have_content('Search for lost items')
  end

  scenario 'Search form accessible to read-only level user' do
    page.set_rack_session(user_role: "Read-only")
    visit '/search_form'
    expect(page).to have_content('Search for lost items')
  end

  scenario 'New items are visable in search all form' do
    visit '/insert_form'
    fill_in "itemDescription", with: "A_NEW_TEST_ITEM"
    fill_in "itemFoundBy", with: "someone"
    fill_in "whereFound", with: "somewhere"
    find_by_id('itemType').find(:xpath, 'option[1]').select_option
    find_by_id('itemLocation').find(:xpath, 'option[1]').select_option
    fill_in "itemDate", with: "9/9/2099"
    find('input[name="commit"]').click
    visit '/search_form'
    find('input[name="commit"]').click
    expect(page).to have_content('A_NEW_TEST_ITEM')
  end

  scenario 'Search form finds found items based on keywords' do
    visit '/search_form'
    find('input[name="commit"]').click
    expect(page).to have_content('A_NEW_TEST_ITEM')
  end

  scenario 'Users can edit found items from search form' do
    visit '/search_form'
    find('input[name="commit"]').click
    first(:link, 'Edit').click
    fill_in "itemDescription", with: "new text for item"
    find('input[name="commit"]').click
    expect(page).to have_content('new text for item')
  end

  scenario 'Staff users can edit found items from search form and mark them as claimed' do
    visit '/search_form'
    find('input[name="commit"]').click
    first(:link, 'Edit').click
    find_by_id('itemStatus').find(:xpath, 'option[2]').select_option
    fill_in "itemDescription", with: "new text for item"
    find('input[name="commit"]').click
    expect(page).to have_content('new text for item')
  end

  scenario 'Search form filters items based on keywords' do
    visit '/insert_form'
    fill_in "itemDescription", with: "HIDE ME"
    find('input[name="commit"]').click
    visit '/search_form'
    fill_in "keyword", with: "TEST ITEM"
    find('input[name="commit"]').click
    expect(page).to have_no_content("HIDE ME")
  end

  scenario 'Search form filters against multiple keywords' do
    visit '/insert_form'
    fill_in "itemDescription", with: "A BLUE TEST ITEM"
    fill_in "itemFoundBy", with: "A user"
    fill_in "whereFound", with: "a cool place"
    find_by_id('itemType').find(:xpath, 'option[1]').select_option
    find_by_id('itemLocation').find(:xpath, 'option[1]').select_option
    fill_in "itemDate", with: "2/2/2099"
    find('input[name="commit"]').click
    visit '/search_form'
    fill_in "keyword", with: "BLUE BOAT ITEM"
    find('input[name="commit"]').click
    expect(page).to have_content("A BLUE TEST ITEM")
  end

  scenario 'Search form filter ignores case sensitivity' do
    visit '/insert_form'
    fill_in "itemDescription", with: "A blue TEST ITEM"
    find('input[name="commit"]').click
    visit '/search_form'
    fill_in "keyword", with: "bLuE"
    find('input[name="commit"]').click
    expect(page).to have_content("A BLUE TEST ITEM")
  end

  scenario 'Home goes to search' do
    visit '/home'
    expect(page).to have_content("Search for lost items")
  end

end
