# -*- encoding : utf-8 -*-
require 'test_helper'
require_relative './merchant_helper_tests'

class AmazonComTest < ActiveSupport::TestCase

  setup do
    @helperClass = AmazonCom
    @url = "http://www.amazon.com/Bravado-Juniors-Michael-Jackson-T-Shirt/dp/B003DA5PLI/ref=sr_1_1?s=apparel&ie=UTF8&qid=1387557746&sr=1-1&keywords=michael+jackson+t-shirt"
    @version = {}
    @helper = AmazonCom.new(@url)

    @availabilities = {
      "Showing 1 - 48 of 213 Results" => false,
      "Showing Top Results for " => false,
    }
    @price_text = {
      input: "$19.61 - $38.99",
      out: "$19.61 - $38.99"
    }
  end

  include MerchantHelperTests

  test "it should process price when range" do
    @version[:price_text] = "$19.61 - $38.99"
    @version = @helper.process_price(@version)
    assert_equal MerchantHelper::UNAVAILABLE, @version[:availability_text]
  end
end
