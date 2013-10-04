# -*- encoding : utf-8 -*-
require 'test_helper'

class HammacherComTest < ActiveSupport::TestCase

  setup do
    @version = {}
    @url = "http://www.hammacher.com/Product/11933"
    @helper = HammacherCom.new(@url)
  end

  test "it should find class from url" do
    assert MerchantHelper.send(:from_url, @url).kind_of?(HammacherCom)
  end

  test "it should process price shipping" do
    @version = @helper.process_shipping_price(@version)
    assert_equal "75,95 $ (à titre indicatif)", @version[:price_shipping_text]
  end
end