# -*- encoding : utf-8 -*-
require 'test_helper'

class SendDownloadLinkControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  test "it should prepare email" do
    xhr :post, :create, data: "amine@shopelia.com"
    assert_equal "amine@shopelia.com", assigns('email')
  end

  test "it should prepare phone" do
    xhr :post, :create, data: "0646403619"
    assert_equal "0033646403619", assigns('phone')
  end

  test 'should do send email' do
    xhr :post, :create, data: "amine@shopelia.com"
    assert_template "email"
    mail = ActionMailer::Base.deliveries.last
    assert mail.subject, "Lien de téléchargement pour shopelia"
  end

  test "should get send sms when phone number is valid" do
    assert_difference "$sms_gateway_count" do
      xhr :post, :create , data: "0033675198934"
      assert_template "sms_success"
    end
  end

  test "should raise error when data is invalid" do
    xhr :post, :create, data: "allo"
    assert_template "error"
  end
end