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

  test "it should process availability" do
    @version[:availability_text] = "$19.61 - $38.99"
    @version = @helper.process_availability(@version)
    assert_equal "Non disponible", @version[:availability_text]
  end

  test "it should process price" do
    @version[:price_text] = "Currently unavailable."
    @version = @helper.process_price(@version)
    assert_equal "0,00 €", @version[:price_text]
  end
end