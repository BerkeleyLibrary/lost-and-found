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
    visit '/insert_form'
    fill_in 'itemDescription', with: "TEST_ITEM"
    fill_in 'itemFoundBy', with: "TEST_ITEM"
    fill_in "whereFound", with: "TEST LOCATION DESCRIPTION"
    find('input[name="commit"]').click
    click_link "Search"
    click_button "Submit"
    first('td').click_link('Edit')
    select "Found", :from => "itemStatus"
    expect(page).to have_selector('#claimedByLabel', visible: true)
  end
end
