require 'test_helper'

class TestModelControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get test_model_index_url
    assert_response :success
  end

  test "should get show" do
    get test_model_show_url
    assert_response :success
  end

  test "should get new" do
    get test_model_new_url
    assert_response :success
  end

  test "should get edit" do
    get test_model_edit_url
    assert_response :success
  end

end
