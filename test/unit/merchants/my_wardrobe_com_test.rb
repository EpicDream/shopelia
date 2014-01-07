# -*- encoding : utf-8 -*-
require 'test_helper'
require_relative './merchant_helper_tests'

class MyWardrobeComTest < ActiveSupport::TestCase

  setup do
    @helperClass = MyWardrobeCom
    @url = "http://www.my-wardrobe.com/ash/neutral-suede-studded-buckle-strap-zoo-trainers-304358"
    @version = {}
    @helper = MyWardrobeCom.new(@url)

    @availabilities = {
      "SORT BY" => false,
    }

    @availability_text = [] # tests are following

    @image_url = {
      input: "http://cdn21.my-wardrobe.com/images/products/3/0/304358/p1_304358.jpg",
      out: "http://cdn21.my-wardrobe.com/images/products/3/0/304358/m1_304358.jpg",
    }
    @images = {
      input: ["http://cdn21.my-wardrobe.com/images/products/3/0/304358/s2_304358.jpg"],
      out: ["http://cdn21.my-wardrobe.com/images/products/3/0/304358/m2_304358.jpg"],
    }
  end

  include MerchantHelperTests

  test "it should process availability in option1" do
    @version[:option1] = {"text" => "IT 40 (only 1 left)"}
    @version = @helper.process_availability(@version)
    assert_equal "only 1 left", @version[:availability_text]
    assert_equal "IT 40", @version[:option1]["text"]
  end
end
