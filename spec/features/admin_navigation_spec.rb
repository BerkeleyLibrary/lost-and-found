require 'rails_helper'

RSpec.describe 'Navigate Admin tasks', type: :feature do
  before :each do
    page.set_rack_session(uid: "013191304")
    page.set_rack_session(user_role: "Administrator")
    page.set_rack_session(user: "A user")
    page.set_rack_session(user_name: "Dante")
    page.set_rack_session(user_active: true)
    visit '/admin'
  end

  scenario 'Admin panel accessible to Admin level user' do
    click_link 'Add/Edit Users'
    expect(page).to have_content('Active Users')
    visit '/admin'
    click_link 'Locations'
    expect(page).to have_content('Active Locations')
    visit '/admin'
    click_link 'Item Types'
    expect(page).to have_content('Active Item Types')
  end

  scenario 'Admin can perform operations on users' do
    click_link 'Add/Edit Users'
    expect(page).to have_content('Active Users')
    find_by_id('user_role').find(:xpath, 'option[1]').select_option
    fill_in 'user_name', with: "TEST_NAME"
    fill_in "uid", with: "123456345"
    find('input[name="commit"]').click
    expect(page).to have_content('123456345')
  end



  scenario 'Admin can de-activate a user' do
    click_link 'Add/Edit Users'
    expect(page).to have_content('Active Users')
    find_by_id('user_role').find(:xpath, 'option[1]').select_option
    fill_in 'user_name', with: "TEST_NAME"
    fill_in "uid", with: "123456345"
    find('input[name="commit"]').click
    expect(page).to have_content('123456345')
    click_link('Deactivate')
    expect(page).to have_content('activate')
  end

  scenario 'Admin can perform operations on item_types' do
    click_link 'Item Types'
    expect(page).to have_content('Active Item Types')
    fill_in 'type_name', with: "Test_type"
    find('input[name="commit"]').click
    expect(page).to have_content('Test Type')
  end

  scenario 'Admin can perform operations on locations' do
    click_link 'Locations'
    expect(page).to have_content('Active Locations')
    fill_in 'location_name', with: "Test Location"
    find('input[name="commit"]').click
    expect(page).to have_content('Test Location')
  end

  scenario 'Admin panel not accessible to staff level user' do
    page.set_rack_session(user_role: "Staff")
    visit '/admin'
    expect(page).to have_content('You must have Admin level permission to view this page')
    visit '/admin_users'
    expect(page).to have_content('You must have Admin level permission to view this page')
    visit '/admin_locations'
    expect(page).to have_content('You must have Admin level permission to view this page')
    visit '/admin_item_types'
    expect(page).to have_content('You must have Admin level permission to view this page')
  end

  scenario 'Admin panel not accessible to read-only level user' do
    page.set_rack_session(user_role: "Read-only")
    visit '/admin'
    expect(page).to have_content('You must have Admin level permission to view this page')
    visit '/admin_users'
    expect(page).to have_content('You must have Admin level permission to view this page')
    visit '/admin_locations'
    expect(page).to have_content('You must have Admin level permission to view this page')
    visit '/admin_item_types'
    expect(page).to have_content('You must have Admin level permission to view this page')
  end
end
