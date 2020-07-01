require 'rails_helper'

RSpec.describe 'Search form tasks', type: :feature do
    before :each do
        mock_omniauth_login "013191304"
        Capybara.current_session.driver.browser.set_cookie "user_role=Administrator"
        Capybara.current_session.driver.browser.set_cookie "user=a user"
        Capybara.current_session.driver.browser.set_cookie "user_name=Dante"
    end

end