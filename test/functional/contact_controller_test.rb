require 'test_helper'

class ContactControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  test "should send contact email" do
    post :create, email:"test@test.fr", name:"Name", message:"Message", format: :json
    assert_response :success
    
    mail = ActionMailer::Base.deliveries.last
    assert mail.present?, "a contact email should have been sent"
  end

end
