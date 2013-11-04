# -*- encoding : utf-8 -*-
require 'test_helper'

class StylebopComTest < ActiveSupport::TestCase

  setup do
    @version = {}
    @url = "http://www.stylebop.com/fr/product_details.php?id=491539"
    @helper = StylebopCom.new(@url)
  end

  test "it should find class from url" do
    assert MerchantHelper.send(:from_url, @url).kind_of?(StylebopCom)
  end

  test "it should process availability" do
    @version[:availability_text] = "Ce produit n'est plus en stock"
    @version = @helper.process_availability(@version)
    assert_equal "Ce produit n'est plus en stock", @version[:availability_text]

    @version[:availability_text] = ""
    @version = @helper.process_availability(@version)
    assert_equal MerchantHelper::AVAILABLE, @version[:availability_text]
  end

  test "it should process price shipping" do
    @version[:price_shipping_text] = ""
    @version = @helper.process_price_shipping(@version)
    assert_equal StylebopCom::DEFAULT_PRICE_SHIPPING, @version[:price_shipping_text]
  end

  test "it should process shipping info" do
    @version[:shipping_info] = ""
    @version = @helper.process_shipping_info(@version)
    assert_equal StylebopCom::DEFAULT_SHIPPING_INFO, @version[:shipping_info]
  end
end