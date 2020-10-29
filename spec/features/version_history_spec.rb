require 'rails_helper'

RSpec.describe 'Version history testing', type: :feature do
    before :each do
        page.set_rack_session(uid: "013191304")
        page.set_rack_session(user_role: "Administrator")
        page.set_rack_session(user: "A user")
        page.set_rack_session(user_name: "Dante")
        page.set_rack_session(user_active: true)
    end

    with_versioning do


  end
end