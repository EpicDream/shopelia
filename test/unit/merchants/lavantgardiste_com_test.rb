# -*- encoding : utf-8 -*-
require 'test_helper'

class LavantgardisteComTest < ActiveSupport::TestCase

  setup do
    @version = {}
    @url = "http://www.lavantgardiste.com/cuisine-bar/1804-set-de-4-moules-a-cupcake-en-forme-de-tasse-a-the-072898701785.html"
    @helper = LavantgardisteCom.new(@url)
  end

  test "it should find class from url" do
    assert MerchantHelper.send(:from_url, @url).kind_of?(LavantgardisteCom)
  end

  test "it should process price shipping" do
    @version[:price_shipping_text] = ""
    @version = @helper.process_shipping_price(@version)
    assert_equal "4,50 € (à titre indicatif)", @version[:price_shipping_text]
  end

  test "it should process shipping info" do
    @version[:shipping_info] = ""
    @version = @helper.process_shipping_info(@version)

    assert_equal "Livraison Colissimo.", @version[:shipping_info]
  end
end