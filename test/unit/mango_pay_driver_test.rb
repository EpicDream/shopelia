# -*- encoding : utf-8 -*-
require 'test_helper'

class MangoPayDriverTest < ActiveSupport::TestCase
 
  test "it should create Shopelia master user" do
    result = MangoPayDriver.create_master_account

    assert_equal "created", result[:status], result[:message]
    u = MangoPay::User.details(MangoPayDriver.get_master_account_id)
    assert_equal "mangopay_master_account@shopelia.com", u['Email']

    result = MangoPayDriver.create_master_account
    assert_equal "error", result[:status]
  end

  test "it should contribute to master account using credit card" do
    MangoPayDriver.create_master_account
    card = { number:"4970100000000154", exp_month:"12", exp_year:"2020", cvv:"123" }
    contribution = MangoPayDriver.credit_master_account card, 1000

    u = MangoPay::User.details(MangoPayDriver.get_master_account_id)
    assert_equal 1000, u['PersonalWalletAmount']

    config = YAML.load(File.open(MangoPayDriver::CONFIG))
    assert_equal 1, config["contributions"].count
  end
  
end
