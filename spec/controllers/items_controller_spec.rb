require "spec_helper"
require "rails_helper"

describe ItemsController, "Items controller", :type => :controller  do
  render_views
    describe "create new item" do
        it "renders the index template" do
            cookies[:expires_at] = { value: "user_active", expires: Time.now + 60.minutes}
            cookies[:user] = User.new()
            cookies[:user_role] = "Admin"
            get :create
            response.body.should match(/LostAndFound/)
        end
    end

    # describe "new item generates create version in item history" do
    #     it "renders the index template" do
    #         cookies[:expires_at] = { value: "user_active", expires: Time.now + 60.minutes}
    #         cookies[:user] = User.new()
    #         cookies[:user_role] = "Admin"
    #         get :create
    #         get item_path(1)
    #         response.body.should match(/LostAndFound/)
    #     end
    # end



end