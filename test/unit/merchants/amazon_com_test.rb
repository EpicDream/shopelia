# -*- encoding : utf-8 -*-
require 'test_helper'

class AmazonComTest < ActiveSupport::TestCase

  setup do
    @version = {}
    @url = "http://www.amazon.com/dp/B0017LIJFY/?tag=047-20"
    @helper = AmazonCom.new(@url)
  end

  test "it should find class from url" do
    assert MerchantHelper.send(:from_url, @url).kind_of?(AmazonCom)
  end

  test "it should process price" do
    @version[:price_text] = "$19.61 - $38.99"
    @version = @helper.process_price(@version)
    assert_equal MerchantHelper::UNAVAILABLE, @version[:availability_text]
  end
end