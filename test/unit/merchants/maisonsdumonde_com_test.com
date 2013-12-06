# -*- encoding : utf-8 -*-
require 'test_helper'
require_relative './merchant_helper_tests'

class MaisonsdumondeComTest < ActiveSupport::TestCase

  setup do
    @helperClass = MaisonsdumondeCom
    @url = "http://www.maisonsdumonde.com/FR/fr/produits/fiche/chaise-de-bureau-bleue-bristol-129673.htm"
    @version = {}
    @helper = MaisonsdumondeCom.new(@url)

    @availabilities = {
    }
    @images = {
      input: ["http://cdn.maisonsdumonde.com/images/cache/6/5/-6504b1af5dbfbe4c7d4edb5d1603b372_w48_h48.jpg"],
      out: ["http://cdn.maisonsdumonde.com/images/cache/6/5/-6504b1af5dbfbe4c7d4edb5d1603b372_w310_h310.jpg"]
    }
  end

  include MerchantHelperTests

  test "it should process price_shipping depending of price" do
    prices = {
      "20 €" => "5,90 € TTC",
      "5 € 10" => "5,90 € TTC",
      "49 € 90" => "5,90 € TTC",
      "50 €" => "9,00 € TTC",
      "99 €" => "9,00 € TTC",
      "150 €" => "19,00 € TTC",
      "999 €" => "59,00 € TTC",
      "1000 €" => MerchantHelper::FREE_PRICE,
    }
    for price, res in prices
      @version[:price_text] = price
      @version = @helper.process_price_shipping @version
      assert_equal res, @version[:price_shipping_text], "with price=#{price}"
    end
  end
end
