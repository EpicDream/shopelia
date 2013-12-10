# -*- encoding : utf-8 -*-
require 'test_helper'
require_relative './merchant_helper_tests'

class ZadigEtVoltaireComTest < ActiveSupport::TestCase

  setup do
    @helperClass = ZadigEtVoltaireCom
    @url = "http://www.zadig-et-voltaire.com/eu/fr/robe-femme-robe-rine-jac-deluxe-marine.html"
    @version = {}
    @helper = ZadigEtVoltaireCom.new(@url)

    @availabilities = {
    }

    @image_url = {
      input: "http://www.zadig-et-voltaire.com/media/catalog/product/cache/2/image/482x564/9df78eab33525d08d6e5fb8d27136e95/S/B/SBCP0403F_marine_1_1.jpg",
      out: "http://www.zadig-et-voltaire.com/media/catalog/product/cache/2/image/9df78eab33525d08d6e5fb8d27136e95/S/B/SBCP0403F_marine_1_1.jpg"
    }
    @images = {
      input: ["http://www.zadig-et-voltaire.com/media/catalog/product/cache/2/thumbnail/53x62/9df78eab33525d08d6e5fb8d27136e95/S/B/SBCP0403F_marine_1_1.jpg"],
      out: ["http://www.zadig-et-voltaire.com/media/catalog/product/cache/2/image/9df78eab33525d08d6e5fb8d27136e95/S/B/SBCP0403F_marine_1_1.jpg"]
    }
  end

  include MerchantHelperTests
end
