# -*- encoding : utf-8 -*-
require 'test_helper'
require_relative './merchant_helper_tests'

class JennyferComTest < ActiveSupport::TestCase

  setup do
    @helperClass = JennyferCom
    @version = {}
    @url = "http://www.jennyfer.com/fr/super-bons-plans-5/pull-effet-mohair-ecru.html"
    @helper = JennyferCom.new(@url)

    @availability_text = [
    ]
    @availabilities = {
    }
    @image_url = {
      input: "http://jnf.media.bbzcdn.com/media/catalog/product/cache/1/image/335x395/9df78eab33525d08d6e5fb8d27136e95/1/0/1000119521_P.jpg?",
      out: "http://jnf.media.bbzcdn.com/media/catalog/product/cache/1/thumbnail/9df78eab33525d08d6e5fb8d27136e95/1/0/1000119521_P.jpg?"
    }
    @images = {
      input: ["http://jnf.media.bbzcdn.com/media/catalog/product/cache/1/thumbnail/44x44/9df78eab33525d08d6e5fb8d27136e95/1/0/1000119521_B.jpg"],
      out: ["http://jnf.media.bbzcdn.com/media/catalog/product/cache/1/thumbnail/9df78eab33525d08d6e5fb8d27136e95/1/0/1000119521_B.jpg"]
    }
  end

  include MerchantHelperTests
end
