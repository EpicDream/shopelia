# -*- encoding : utf-8 -*-
require 'test_helper'
require_relative './merchant_helper_tests'

class ClaudiepierlotComTest < ActiveSupport::TestCase

  setup do
    @helperClass = ClaudiepierlotCom
    @url = "http://www.claudiepierlot.com/fr/chaussures/chaussure-alma.html?color=1242"
    @version = {}
    @helper = ClaudiepierlotCom.new(@url)

    @availabilities = {
    }
    @image_url = {
      input: "http://www.claudiepierlot.com/media/catalog/product/cache/1/image/500x734/9df78eab33525d08d6e5fb8d27136e95/a/l/alma_blanc-blanc-b.jpg",
      out: "http://www.claudiepierlot.com/media/catalog/product/cache/1/image/1000x1465/9df78eab33525d08d6e5fb8d27136e95/a/l/alma_blanc-blanc-b.jpg"
    }
    @images = {
      input: ["http://www.claudiepierlot.com/media/catalog/product/cache/1/thumbnail/54x80/9df78eab33525d08d6e5fb8d27136e95/a/l/alma_blanc-blanc-1.jpg"],
      out: ["http://www.claudiepierlot.com/media/catalog/product/cache/1/image/1000x1465/9df78eab33525d08d6e5fb8d27136e95/a/l/alma_blanc-blanc-1.jpg"]
    }
  end

  include MerchantHelperTests
end
