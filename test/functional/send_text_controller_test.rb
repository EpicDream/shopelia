require 'test_helper'

class SendTextControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  test 'should do send email' do
    get :send_text_message, email: "amine@shopelia"
    assert_response :success
    mail = ActionMailer::Base.deliveries.last
    assert mail.subject, "Lien de t?l?chargement pour shopelia"
  end

  test "should get send sms when phone number is valid" do
    #get :send_text_message , phone_number: "0033675198934"
    #assert_response :success
  end

  test "should get error sms when phone number is invalid" do
    get :send_text_message, phone_number: "allo"
    p JSON.parse(response.body)["messages"][0]["error-text"]
    assert JSON.parse(response.body)['messages'][0]["error-text"],"to address 'allo' is not numeric"
  end

end
