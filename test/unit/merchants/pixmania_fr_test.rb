# -*- encoding : utf-8 -*-
require 'test_helper'

class PixmaniaFrTest < ActiveSupport::TestCase

  setup do
    @version = {}
    @url = "http://www.pixmania.fr/bridge/nikon-coolpix-p520-noir/21169997-a.html"
    @helper = PixmaniaFr.new(@url)
  end

  test "it should find class from url" do
    assert MerchantHelper.send(:from_url, @url).kind_of?(PixmaniaFr)
  end

  test "it should process price shipping" do
    @version[:price_shipping_text] = "5.50"
    @version = @helper.process_price_shipping(@version)
    assert_equal "5.50", @version[:price_shipping_text]

    @version[:price_shipping_text] = ""
    @version = @helper.process_price_shipping(@version)
    assert_equal PixmaniaFr::DEFAULT_PRICE_SHIPPING, @version[:price_shipping_text]

    @version[:price_shipping_text] = "Modes de livraison"
    @version = @helper.process_price_shipping(@version)
    assert_equal PixmaniaFr::DEFAULT_PRICE_SHIPPING, @version[:price_shipping_text]
  end

  test "it should process shipping info" do
    @version[:shipping_info] = ""
    @version = @helper.process_shipping_info(@version)
    assert_equal PixmaniaFr::DEFAULT_SHIPPING_INFO, @version[:shipping_info]
  end
end