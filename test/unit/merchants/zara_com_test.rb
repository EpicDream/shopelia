# -*- encoding : utf-8 -*-
require 'test_helper'

class ZaraComTest < ActiveSupport::TestCase

  setup do
    @version = {}
    @url = "http://www.zara.com/fr/fr/homme/sweat-shirts/sweat-%C3%A0-d%C3%A9tail-en-similicuir-c309502p1582520.html"
    @helper = ZaraCom.new(@url)
  end

  test "it should find class from url" do
    assert MerchantHelper.send(:from_url, @url).kind_of?(ZaraCom)
  end

  test "it should canonize" do
  end

  test "it should process availability" do
    text = "Indisponible"
    @version[:availability_text] = text
    @version = @helper.process_availability(@version)
    assert_equal text, @version[:availability_text]

    @version[:availability_text] = ""
    @version = @helper.process_availability(@version)
    assert_equal MerchantHelper::AVAILABLE, @version[:availability_text]
  end

  test "it should parse specific availability" do
  end

  test "it should process price_shipping if empty" do
    @version[:price_shipping_text] = ""
    @version = @helper.process_price_shipping(@version)
    assert_equal ZaraCom::DEFAULT_PRICE_SHIPPING, @version[:price_shipping_text]
  end

  test "it should process price_shipping if greater than limit" do
    @version[:price_text] = sprintf("%.2f €", ZaraCom::FREE_SHIPPING_LIMIT-1)
    @version = @helper.process_price_shipping(@version)
    assert_equal ZaraCom::DEFAULT_PRICE_SHIPPING, @version[:price_shipping_text]

    @version[:price_text] = sprintf("%.2f €", ZaraCom::FREE_SHIPPING_LIMIT)
    @version = @helper.process_price_shipping(@version)
    assert_equal MerchantHelper::FREE_PRICE, @version[:price_shipping_text]
  end
end
