# -*- encoding : utf-8 -*-
require 'test_helper'

class BhdiscountComTest < ActiveSupport::TestCase

  setup do
    @version = {}
    @url = "http://www.bhdiscount.com/fr/smartphone/smartphone-rex-80-gts5220ibrdbt-samsung.html?source=5"
    @helper = BhdiscountCom.new(@url)
  end

  test "it should find class from url" do
    assert MerchantHelper.send(:from_url, @url).kind_of?(BhdiscountCom)
  end

  test "it should canonize" do
  end

  test "it should process availability" do
  end

  test "it should parse specific availability" do
    assert_equal true, MerchantHelper.parse_availability("Delais produit", @url)[:avail]
  end

  test "it should process price_shipping if empty" do
    @version[:price_shipping_text] = ""
    @version = @helper.process_price_shipping(@version)
    assert_equal BhdiscountCom::DEFAULT_PRICE_SHIPPING, @version[:price_shipping_text]
  end
end
