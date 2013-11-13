# -*- encoding : utf-8 -*-
require 'test_helper'

class ThebodyshopFrTest < ActiveSupport::TestCase

  setup do
    @version = {}
    @url = "http://www.thebodyshop.fr/parfums/pour-lui/baume-apres-rasage-kistna.aspx"
    @helper = ThebodyshopFr.new(@url)
  end

  test "it should find class from url" do
    assert MerchantHelper.send(:from_url, @url).kind_of?(ThebodyshopFr)
  end
  
  test "it should process_price_shipping (1)" do
    @version[:price_text] = "8.95 €"
    @version = @helper.process_shipping_price(@version)
    assert_equal ThebodyshopFr::DEFAULT_PRICE_SHIPPING, @version[:price_shipping_text]
  end

  test "it should process_price_shipping (2)" do
    @version[:price_text] = "40,90 €"
    @version = @helper.process_shipping_price(@version)
    assert_equal "0.00", @version[:price_shipping_text]
  end

  test "it should process availability" do
    @version[:availability_text] = ""
    @version = @helper.process_availability(@version)
    assert_equal MerchantHelper::AVAILABLE, @version[:availability_text]

    str = "Il ne reste plus que 6 exemplaire(s) en stock."
    @version[:availability_text] = str
    @version = @helper.process_availability(@version)
    assert_equal str, @version[:availability_text]
  end
end
