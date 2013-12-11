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
    @options = {
      level: 1,
      input: {"tagName"=>"SPAN", "id"=>"", "class"=>"", "text"=>"", "location"=>"http://www.paulandjoe.com/fr/femme/shop-by-categorie/vetements/tops/haut-nuibelle-gris.html", "style"=>"background-color:#A3A3A3;", "xpath"=>"//div[@id=\"product-options-wrapper\"]/div[1]/ul/li/a/span", "cssPath"=>"div#product-options-wrapper > div.color > ul > li > a > span", "saturnPath"=>".product-options .color li span", "hash"=>"SPAN;;;http://www.paulandjoe.com/fr/femme/shop-by-categorie/vetements/tops/haut-nuibelle-gris.html;;"},
      out: {"tagName"=>"SPAN", "id"=>"", "class"=>"", "text"=>"#A3A3A3", "location"=>"http://www.paulandjoe.com/fr/femme/shop-by-categorie/vetements/tops/haut-nuibelle-gris.html", "style"=>"background-color:#A3A3A3;", "xpath"=>"//div[@id=\"product-options-wrapper\"]/div[1]/ul/li/a/span", "cssPath"=>"div#product-options-wrapper > div.color > ul > li > a > span", "saturnPath"=>".product-options .color li span", "hash"=>"SPAN;;;http://www.paulandjoe.com/fr/femme/shop-by-categorie/vetements/tops/haut-nuibelle-gris.html;;"}
    }
  end

  include MerchantHelperTests
end
