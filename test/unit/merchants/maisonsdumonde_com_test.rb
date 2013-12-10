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
    @price_shipping_text = [
      {price_shipping_text: "", price_text: "20 €", out: "5,90 € TTC"},
      {price_shipping_text: "", price_text: "5 € 10", out: "5,90 € TTC"},
      {price_shipping_text: "", price_text: "49 € 90", out: "5,90 € TTC"},
      {price_shipping_text: "", price_text: "50 €", out: "9,00 € TTC"},
      {price_shipping_text: "", price_text: "99 €", out: "9,00 € TTC"},
      {price_shipping_text: "", price_text: "150 €", out: "19,00 € TTC"},
      {price_shipping_text: "", price_text: "999 €", out: "59,00 € TTC"},
      {price_shipping_text: "", price_text: "1000 €", out: MerchantHelper::FREE_PRICE},
    ]
    @images = {
      input: ["http://cdn.maisonsdumonde.com/images/cache/6/5/-6504b1af5dbfbe4c7d4edb5d1603b372_w48_h48.jpg"],
      out: ["http://cdn.maisonsdumonde.com/images/cache/6/5/-6504b1af5dbfbe4c7d4edb5d1603b372_w310_h310.jpg"]
    }
  end

  include MerchantHelperTests
end
