require 'test_helper'

class HomeControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  setup do
    @user = users(:elarch)
  end

  test "should get index" do
    get :index
    assert_response :success
  end

  test "should show connect options if not logged" do
    get :connect
    assert_response :success
  end

  test "should redirect to home on connect if already logged and no saved page" do
    sign_in @user
    get :connect
    assert_redirected_to home_index_path
  end
end