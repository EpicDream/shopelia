# -*- encoding : utf-8 -*-
require 'test_helper'
require_relative './merchant_helper_tests'

class ZaraComTest < ActiveSupport::TestCase

  setup do
    @helperClass = ZaraCom
    @url = "http://www.zara.com/fr/fr/homme/sweat-shirts/sweat-%C3%A0-d%C3%A9tail-en-similicuir-c309502p1582520.html"
    @version = {}
    @helper = ZaraCom.new(@url)

    @availabilities = {
      "No results have been found for crop top turtleneck" => false,
      "Results for: plaid dress" => false,
      "Aucun résultat n'a été trouvé pour bottines talon pais Vous trouverez ci-après les résultats pour bottines talon epais" => false,
    }
    @price_shipping_text = [{
      input: "",
      price_text: "14,90",
      out: @helper.default_price_shipping,
    }, {
      input: "",
      price_text: "100,90",
      out: MerchantHelper::FREE_PRICE,
    }]
  end

  include MerchantHelperTests
end
