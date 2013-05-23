require 'test_helper'

class Api::V1::Users::ResetControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  fixtures :users

  test "it should send password if email exists" do
    post :create, data:{email:"elarch@gmail.com"}, format: :json
    assert_response :success
    mail = ActionMailer::Base.deliveries.last
    assert mail.present?, "a password reset email should have been sent"
  end

  test "it should fail email doesn't exist" do
    post :create, data:{email:"toto@toto.fr"}, format: :json
    assert_response :not_found
  end

  test "bad request" do
    post :create, {}, format: :json
    assert_response :unprocessable_entity
  end
  
end

