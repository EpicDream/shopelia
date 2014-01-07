# -*- encoding : utf-8 -*-
require 'test_helper'
require_relative './merchant_helper_tests'

class NordstromComTest < ActiveSupport::TestCase

  setup do
    @helperClass = NordstromCom
    @url = "http://shop.nordstrom.com/s/dolce-vita-bex-flat/3530180?origin=category"
    @version = {}
    @helper = NordstromCom.new(@url)

    @canonize = {
      input: @url,
      out: "http://shop.nordstrom.com/s/dolce-vita-bex-flat/3530180"
    }
    @availabilities = {
      "2,003ITEMS" => false,
      "No results were found for “dolcevitaboots”" => false,
    }

    @image_url = {
      input: "http://g.nordstromimage.com/imagegallery/store/product/Large/17/_8448217.jpg",
      out: "http://g.nordstromimage.com/imagegallery/store/product/zoom/17/_8448217.jpg",
    }
    @images = {
      input: ["http://g.nordstromimage.com/imagegallery/store/product/Mini/4/_8448204.jpg"],
      out: ["http://g.nordstromimage.com/imagegallery/store/product/zoom/4/_8448204.jpg"],
    }
  end

  include MerchantHelperTests
end
