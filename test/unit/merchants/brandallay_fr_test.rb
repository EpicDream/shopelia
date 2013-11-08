# -*- encoding : utf-8 -*-
require 'test_helper'

class BrandallayFrTest < ActiveSupport::TestCase

  setup do
    @version = {}
    @url = "http://www.brandalley.fr/fiche-Produit/Rayon-813505"
    @helper = BrandallayFr.new(@url)
  end

  test "it should process price_shipping if empty" do
    @version[:price_shipping_text] = ""
    @version = @helper.process_price_shipping(@version)
    assert_equal BrandallayFr::DEFAULT_PRICE_SHIPPING, @version[:price_shipping_text]
  end

  test "it should process price_shipping if greater than limit" do
    @version[:price_text] = sprintf("%.2f €", BrandallayFr::FREE_SHIPPING_LIMIT-1)
    @version = @helper.process_price_shipping(@version)
    assert_equal BrandallayFr::DEFAULT_PRICE_SHIPPING, @version[:price_shipping_text]

    @version[:price_text] = sprintf("%.2f €", BrandallayFr::FREE_SHIPPING_LIMIT)
    @version = @helper.process_price_shipping(@version)
    assert_equal MerchantHelper::FREE_PRICE, @version[:price_shipping_text]
  end
end
