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

  scenario 'Admin cannot upload users with non-numeric ids' do
    click_link 'Add/Edit Users'
    expect(page).to have_content('Active Users')
    find_by_id('user_role').find(:xpath, 'option[1]').select_option
    fill_in 'user_name', with: "TEST_NAME"
    fill_in "uid", with: "a1"
    find('input[name="commit"]').click
    expect(page).to have_content('Error: UID is not numeric')
  end

  scenario 'Admin cannot upload duplicate user ids' do
    click_link 'Add/Edit Users'
    expect(page).to have_content('Active Users')
    find_by_id('user_role').find(:xpath, 'option[1]').select_option
    fill_in 'user_name', with: "TEST_NAME"
    fill_in "uid", with: "123456789"
    find('input[name="commit"]').click
    find_by_id('user_role').find(:xpath, 'option[1]').select_option
    fill_in 'user_name', with: "TEST_NAME"
    fill_in "uid", with: "123456789"
    find('input[name="commit"]').click
    expect(page).to have_content('Error: UID already exists')
  end

  scenario 'Admin can deactivate a user' do
    click_link 'Add/Edit Users'
    expect(page).to have_content('Active Users')
    find_by_id('user_role').find(:xpath, 'option[1]').select_option
    fill_in 'user_name', with: "TEST_NAME"
    fill_in "uid", with: "123456345"
    find('input[name="commit"]').click
    expect(page).to have_content('123456345')
    first(:link, "Deactivate").click
    expect(page).to have_content('Success: User Test Name status updated!')
  end

  scenario 'Admin can edit a user' do
    click_link 'Add/Edit Users'
    expect(page).to have_content('Active Users')
    find_by_id('user_role').find(:xpath, 'option[1]').select_option
    fill_in 'user_name', with: "edit_test"
    fill_in "uid", with: "115"
    find('input[name="commit"]').click
    expect(page).to have_content('115')
    first(:link,'Edit').click
    find_by_id('user_role').find(:xpath, 'option[1]').select_option
    fill_in 'user_name', with: "edit_test_updated"
    fill_in "uid", with: "116"
    find('input[name="commit"]').click
   expect(page).to have_content('116')
   expect(page).to have_content('edit_test_updated')
  end

  scenario 'Admin can edit a user, but cannot input a non-numeric id' do
    click_link 'Add/Edit Users'
    expect(page).to have_content('Active Users')
    find_by_id('user_role').find(:xpath, 'option[1]').select_option
    fill_in 'user_name', with: "TEST_NAME"
    fill_in "uid", with: "123456345"
    find('input[name="commit"]').click
    expect(page).to have_content('123456345')
    first(:link, "Edit").click
    expect(page).to have_content('Edit user')
    fill_in 'user_name', with: "NEW_NAME"
    fill_in "uid", with: "1a2b3c4d5c"
   click_button('Update user')
   expect(page).to have_content('Error: UID 1a2b3c4d5c is not numeric')
  end

  scenario 'Admin can edit a user, but cannot input an already existing uid' do
    click_link 'Add/Edit Users'
    expect(page).to have_content('Active Users')
    find_by_id('user_role').find(:xpath, 'option[1]').select_option
    fill_in 'user_name', with: "TEST_NAME"
    fill_in "uid", with: "123456345"
    find('input[name="commit"]').click
    expect(page).to have_content('123456345')
    find_by_id('user_role').find(:xpath, 'option[1]').select_option
    fill_in 'user_name', with: "TEST_NAME2"
    fill_in "uid", with: "321"
    find('input[name="commit"]').click
    first(:link, "Edit").click
    expect(page).to have_content('Edit user')
    fill_in 'user_name', with: "NEW_NAME"
    fill_in "uid", with: "321"
   click_button('Update user')
   expect(page).to have_content('Error: UID 321 already exists')
  end

  scenario 'Admin can perform operations on item_types' do
    click_link 'Item Types'
    expect(page).to have_content('Active Item Types')
    fill_in 'type_name', with: "Test_type"
    find('input[name="commit"]').click
    expect(page).to have_content('Test Type')
  end



  scenario 'Admin cannot upload duplicate item_types' do
    click_link 'Item Types'
    expect(page).to have_content('Active Item Types')
    fill_in 'type_name', with: "Test_type"
    find('input[name="commit"]').click
    expect(page).to have_content('Test Type')
    fill_in 'type_name', with: "Test_type"
    find('input[name="commit"]').click
    expect(page).to have_content('Error: Item Type Test Type Already exists')
  end

  scenario 'Admin can edit item_types' do
    click_link 'Item Types'
    expect(page).to have_content('Active Item Types')
    fill_in 'type_name', with: "Test_type"
    find('input[name="commit"]').click
    expect(page).to have_content('Test Type')
    click_link "Edit"
    expect(page).to have_content('Edit item type')
    fill_in 'type_name', with: "Test item Updated"
    find('input[name="commit"]').click
    expect(page).to have_content('Test Item Updated')
  end

  scenario 'Admin may deactivate item types' do
    click_link 'Item Types'
    fill_in 'type_name', with: "Test Type"
    find('input[name="commit"]').click
    fill_in 'type_name', with: "Test Type"
    first(:link, "Deactivate").click
    expect(page).to have_content('Success: Item type Test Item Updated status updated!')
  end

  scenario 'Admin may upload item types in batches, but cannot upload empty files' do
    visit '/admin_migration_item_types'
    expect(page).to have_content('Add Item types')
    click_button "Add Item types"
    expect(page).to have_content('Error: File unreadable')
  end

  scenario 'Admin may upload item types in batches' do
    visit '/admin_migration_item_types'
    expect(page).to have_content('Add Item types')
    attach_file('batch_file', File.absolute_path('./spec/data/batches/item_type_batch.txt'))
    click_button "Add Item types"
    expect(page).to have_content('Success: item types added')
  end

  scenario 'Admin may upload items in batches' do
    visit '/admin_migration_items'
    attach_file('batch_file', File.absolute_path('./spec/data/batches/item_batch.txt'))
    click_button "Add Items"
    expect(page).to have_content('items added')
  end

  scenario 'Admin may upload items in batches, but may not use an empty file' do
    visit '/admin_migration_items'
    click_button "Add Items"
    expect(page).to have_content('Error: File unreadable')
  end

  scenario 'Admin can perform operations on locations' do
    click_link 'Locations'
    expect(page).to have_content('Active Locations')
    fill_in 'location_name', with: "Test Location"
    find('input[name="commit"]').click
    expect(page).to have_content('Test Location')
  end

  scenario 'Admin cannot create location duplicates' do
    click_link 'Locations'
    expect(page).to have_content('Active Locations')
    fill_in 'location_name', with: "Test Location"
    find('input[name="commit"]').click
    fill_in 'location_name', with: "Test Location"
    find('input[name="commit"]').click
    expect(page).to have_content('Already exists')
  end

  scenario 'Admin may edit locations' do
    click_link 'Locations'
    expect(page).to have_content('Active Locations')
    fill_in 'location_name', with: "Test Location"
    find('input[name="commit"]').click
    fill_in 'location_name', with: "Test Location"
    click_link "Edit"
    expect(page).to have_content('Edit location')
    fill_in 'location_name', with: "Test Location Updated"
    find('input[name="commit"]').click
    expect(page).to have_content('Test Location Updated')
  end

  scenario 'Admin may deactivate locations' do
    click_link 'Locations'
    expect(page).to have_content('Active Locations')
    fill_in 'location_name', with: "Test Location"
    find('input[name="commit"]').click
    fill_in 'location_name', with: "Test Location"
    first(:link, "Deactivate").click
    expect(page).to have_content('Success: Location Test Location status updated!')
  end

  scenario 'Admin may upload locations in batches, but cannot upload empty files' do
    visit '/admin_migration_locations'
    expect(page).to have_content('Add locations')
    click_button "Add Locations"
    expect(page).to have_content('Error: File unreadable')
  end

  scenario 'Admin may upload locations in batches' do
    visit '/admin_migration_locations'
    expect(page).to have_content('Add locations')
    attach_file('batch_file', File.absolute_path('./spec/data/batches/location_batch.txt'))
    click_button "Add Locations"
    expect(page).to have_content('Success: Locations added')
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
