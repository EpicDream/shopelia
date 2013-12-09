# -*- encoding : utf-8 -*-
require 'test_helper'
require_relative './merchant_helper_tests'

class MistergooddealComTest < ActiveSupport::TestCase

  setup do
    @helperClass = MistergooddealCom
    @url = "http://www.mistergooddeal.com/petit-electromenager/aspirateur/aspirateur-sans-sac/dyson-dc19t2-origin.htm"
    @version = {}
    @helper = MistergooddealCom.new(@url)

    @availabilities = {
      "152 produits" => false,
    }
  end

  include MerchantHelperTests
end
