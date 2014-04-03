require 'test_helper'

class Api::Flink::Flinkers::PasswordsControllerTest < ActionController::TestCase     
  include Devise::TestHelpers

  setup do
    @flinker = flinkers(:fanny)
    @flinker.update_attributes(email:"anoiaque@me.com")
  end
  
  test "send password reset email to current flinker" do
    Flinker.any_instance.expects(:send_reset_password_instructions)

    post :create, email:"anoiaque@me.com"
    
    assert_response :success
  end

end