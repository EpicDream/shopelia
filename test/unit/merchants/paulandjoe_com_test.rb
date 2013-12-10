# -*- encoding : utf-8 -*-
require 'test_helper'
require_relative './merchant_helper_tests'

class PaulandjoeComTest < ActiveSupport::TestCase

  setup do
    @helperClass = PaulandjoeCom
    @url = "http://www.paulandjoe.com/fr/femme/shop-by-categorie/vetements/combinaisons/combinaison-pavie-noir.html"
    @version = {}
    @helper = PaulandjoeCom.new(@url)

    @availabilities = {
    }
    @image_url = {
      input: "http://www.paulandjoe.com/media/catalog/product/cache/1/image/412x618/9df78eab33525d08d6e5fb8d27136e95/p/a/pavie_noir-noir-1.jpg",
      out: "http://www.paulandjoe.com/media/catalog/product/cache/1/image/1000x1340/9df78eab33525d08d6e5fb8d27136e95/p/a/pavie_noir-noir-1.jpg",
    }
    @images = {
      input: ["http://www.paulandjoe.com/media/catalog/product/cache/1/image/412x618/9df78eab33525d08d6e5fb8d27136e95/p/a/pavie_noir-noir-1.jpg"],
      out: ["http://www.paulandjoe.com/media/catalog/product/cache/1/image/1000x1340/9df78eab33525d08d6e5fb8d27136e95/p/a/pavie_noir-noir-1.jpg"],
    }
  end

  include MerchantHelperTests
end
