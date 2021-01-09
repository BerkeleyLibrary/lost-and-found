require 'rails_helper'

RSpec.describe 'Search form tasks', type: :feature do
  before :each do
    page.set_rack_session(uid: "013191304")
    page.set_rack_session(user_role: "Administrator")
    page.set_rack_session(user: "A user")
    page.set_rack_session(user_name: "Dante")
    page.set_rack_session(user_active: true)
  end

  scenario 'Updated items are tracked in change history' do

    visit '/admin'
    click_link 'Item Types'
    fill_in 'type_name', with: "Test_type"
    find('input[name="commit"]').click
    visit '/admin'
    click_link 'Locations'
    fill_in 'location_name', with: "Test Location"
    find('input[name="commit"]').click

    visit '/insert_form'
    fill_in "itemDescription", with: "TEST_ITEM"
    fill_in "itemFoundBy", with: "A user"
    fill_in "whereFound", with: "a cool place"
    find_by_id('itemType').find(:xpath, 'option[1]').select_option
    find_by_id('itemLocation').find(:xpath, 'option[1]').select_option
    fill_in "itemDate", with: "2/2/2099"
    find('input[name="commit"]').click
    click_link "Search"
    click_button "Submit"
    first('td').click_link('Edit')
    select "Found", :from => "itemStatus"
    expect(page).to have_selector('#claimedByLabel', visible: true)
  end
end
