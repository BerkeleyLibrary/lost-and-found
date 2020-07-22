require 'rails_helper'

RSpec.describe 'Navigate Admin tasks', type: :feature do
  before :each do
    mock_omniauth_login '013191304'
    Capybara.current_session.driver.browser.set_cookie 'user_role=Administrator'
    Capybara.current_session.driver.browser.set_cookie 'user=a user'
    Capybara.current_session.driver.browser.set_cookie 'user_name=Dante'
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
    visit '/admin'
    click_link 'View all items'
    expect(page).to have_content('Found Items')
  end

  scenario 'Admin panel not accessible to staff level user' do
    Capybara.current_session.driver.browser.set_cookie 'user_role=staff'
    visit '/admin'
    expect(page).to have_content('You must have Admin level permission to view this page')
  end

  scenario 'Admin panel not accessible to read-only level user' do
    Capybara.current_session.driver.browser.set_cookie 'user_role=read-only'
    visit '/admin'
    expect(page).to have_content('You must have Admin level permission to view this page')
  end
end
