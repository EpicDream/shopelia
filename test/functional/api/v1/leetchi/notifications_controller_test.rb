require 'test_helper'

class Api::V1::Leetchi::NotificationsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  test "it should process notifications" do
    get :index, operation:"{'TransactionID':18}"

    assert_response :success
  end

end

