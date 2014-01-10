# -*- encoding : utf-8 -*-
require 'test_helper'
require_relative './merchant_helper_tests'

class LuisaviaromaComTest < ActiveSupport::TestCase

  setup do
    @helperClass = LuisaviaromaCom
    @url = "http://www.luisaviaroma.com/index.aspx?#ItemSrv.ashx|SeasonId=57I&CollectionId=07H&ItemId=12"
    @version = {}
    @helper = LuisaviaromaCom.new(@url)

    @availabilities = {
      "NOUVEAUTÉS" => false,
    }

    @price_shipping_text = {input: "Supplément de 5 €", out: @helper.default_price_shipping}
    @shipping_info = {
      input: "Délai de 5 jours",
      out: @helper.default_shipping_info
    }
    @image_url = {
      input: "http://images.luisaviaroma.com/Big57I/07H/012_26efd1da-d067-4a0b-a075-af1964dedbd1.JPG",
      out: "http://images.luisaviaroma.com/Zoom57I/07H/012_26efd1da-d067-4a0b-a075-af1964dedbd1.JPG"
    }
    @images = {
      input:["http://images.luisaviaroma.com/Total57I/07H/012_fe8525c8-d6c2-49ff-9715-0bc6841a8bbe.JPG"],
      out: ["http://images.luisaviaroma.com/Zoom57I/07H/012_fe8525c8-d6c2-49ff-9715-0bc6841a8bbe.JPG"]
    }
  end

  include MerchantHelperTests
end
