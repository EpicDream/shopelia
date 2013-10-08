# -*- encoding : utf-8 -*-
require 'test_helper'

class LageekerieComTest < ActiveSupport::TestCase

  setup do
    @version = {}
    @url = "http://lageekerie.com/rideau-de-douche/167-savon-manette-wii-geek.html"
    @helper = LageekerieCom.new(@url)
  end

  test "it should find class from url" do
    assert MerchantHelper.send(:from_url, @url).kind_of?(LageekerieCom)
  end

  test "it should process price shipping" do
    @version[:price_shipping_text] = ""
    @version = @helper.process_shipping_price(@version)
    assert_equal "3,90 € (à titre indicatif)", @version[:price_shipping_text]
  end

  test "it should process shipping info" do
    @version[:shipping_info] = ""
    @version = @helper.process_shipping_info(@version)
    assert_equal "Livraison SoColissimo.", @version[:shipping_info]
  end
end