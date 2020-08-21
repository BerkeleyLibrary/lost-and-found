require 'rails_helper'

RSpec.describe 'Navigate Admin tasks', type: :feature do
  before :each do
    mock_omniauth_login '013191304'
    page.set_rack_session(user_role: "Administrator")
    page.set_rack_session(user: "A user")
    page.set_rack_session(user_name: "Dante")
    page.set_rack_session(user_active: true)
    visit '/admin'
  end

  # scenario 'Admin panel accessible to Admin level user' do
  #   click_link 'Add/Edit Users'
  #   expect(page).to have_content('Active Users')
  #   visit '/admin'
  #   click_link 'Locations'
  #   expect(page).to have_content('Active Locations')
  #   visit '/admin'
  #   click_link 'Item Types'
  #   expect(page).to have_content('Active Item Types')
  #   visit '/admin'
  #   click_link 'View all items'
  #   expect(page).to have_content('Found Items')
  # end

  scenario 'Admin panel not accessible to staff level user' do
    page.set_rack_session(user_role: "Staff")
    visit '/admin'
    expect(page).to have_content('You must have Admin level permission to view this page')
  end

  scenario 'Admin panel not accessible to read-only level user' do
    page.set_rack_session(user_role: "Read-only")
    visit '/admin'
    expect(page).to have_content('You must have Admin level permission to view this page')
  end
end
