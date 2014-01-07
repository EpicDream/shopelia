# -*- encoding : utf-8 -*-
require 'test_helper'
require_relative './merchant_helper_tests'

class SpartooComTest < ActiveSupport::TestCase

  setup do
    @helperClass = SpartooCom
    @url = "http://www.spartoo.com/Stephane-Gontard-PAD-x160260.php"
    @version = {}
    @helper = SpartooCom.new(@url)

    @availabilities = {
      "(2942 articles)" => false,
    }

    @price_shipping_text = [{
      price_text: "75 €",
      price_strikeout_text: "100 €",
      out: "5 €",
    },{
      price_text: "85 €",
      price_strikeout_text: "100 €",
      out: MerchantHelper::FREE_PRICE,
    },{
      price_text: "30 €",
      out: "5 €",
    },{
      price_text: "55 €",
      out: "3 €",
    },{
      price_text: "70 €",
      out: MerchantHelper::FREE_PRICE,
    }]

    @options = [{
      option1: {"text" => "Autres couleurs disponibles pour LASAM"},
      image_url: "http://photos6.spartoo.com/photos/160/160260/160260_1200_A.jpg",
      out: {"src" => "http://photos6.spartoo.com/photos/160/160260/160260_40_A.jpg"},
    },{
      option1: {"text" => "Autres couleurs disponibles pour LASAM"},
      image_url: "http://photos6.spartoo.com/photos/160/160260/160260_350_A.jpg",
      out: {"src" => "http://photos6.spartoo.com/photos/160/160260/160260_350_A.jpg"},
    },{
      option1: {"src" => "http://photos6.spartoo.com/photos/217/217093/217093_40_A.jpg"},
      image_url: "http://photos6.spartoo.com/photos/160/160260/160260_1200_A.jpg",
      out: {"src" => "http://photos6.spartoo.com/photos/217/217093/217093_40_A.jpg"},
    }]

    @image_url = {
      input: "http://photos6.spartoo.com/photos/160/160260/160260_350_A.jpg",
      out: "http://photos6.spartoo.com/photos/160/160260/160260_1200_A.jpg",
    }
    @images = {
      input: ["http://photos6.spartoo.com/photos/160/160260/160260_40_G.jpg"],
      out: ["http://photos6.spartoo.com/photos/160/160260/160260_1200_G.jpg"],
    }
  end

  include MerchantHelperTests
end
