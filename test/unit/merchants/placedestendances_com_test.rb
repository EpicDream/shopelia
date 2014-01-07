# -*- encoding : utf-8 -*-
require 'test_helper'
require_relative './merchant_helper_tests'

class PlacedestendancesComTest < ActiveSupport::TestCase

  setup do
    @helperClass = PlacedestendancesCom
    @url = "http://susana-traca.placedestendances.com/collection-susana-traca/pret-a-porter-mode-femme-fashion/chaussures-ballerines/slippers/rouge/fiche-produit,1041109,1041146"
    @version = {}
    @helper = PlacedestendancesCom.new(@url)

    @availabilities = {
      "351 modèles" => false,
    }
    @price_shipping_text = [{
      price_text: "45 €",
      out: @helper.default_price_shipping,
    },{
      price_text: "120 €",
      out: MerchantHelper::FREE_PRICE,
    }]
    @options = [{
      option1: {"text" => "Coloris : Blanc"},
      image_url: "http://media-cache.placedestendances.com/image/69/3/463693.16.jpg",
      out: {"text" => "Coloris : Blanc", "src" => "http://media-cache.placedestendances.com/image/69/3/463693.36.jpg"},
    },{
      option1: {"text" => "Coloris : Blanc"},
      image_url: "http://media-cache.placedestendances.com/image/69/3/463693.jpg",
      out: {"text" => "Coloris : Blanc", "src" => "http://media-cache.placedestendances.com/image/69/3/463693.36.jpg"},
    },{
      option1: {"src" => "http://media-cache.placedestendances.com/image/69/3/463693.36.jpg"},
      image_url: "http://media-cache.placedestendances.com/image/69/3/463693.jpg",
      out: {"src" => "http://media-cache.placedestendances.com/image/69/3/463693.36.jpg"},
    }]
    @image_url = {
      input: "http://media-cache.placedestendances.com/image/69/3/463693.129.jpg",
      out: "http://media-cache.placedestendances.com/image/69/3/463693.jpg",
    }
    @images = {
      input: ["http://media-cache.placedestendances.com/image/69/3/463693.16.jpg"],
      out: ["http://media-cache.placedestendances.com/image/69/3/463693.jpg"],
    }
  end

  include MerchantHelperTests
end
