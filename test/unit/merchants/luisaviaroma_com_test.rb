# -*- encoding : utf-8 -*-
require 'test_helper'

class LuisaviaromaComTest < ActiveSupport::TestCase

  setup do
    @version = {}
    @url = "http://www.luisaviaroma.com/index.aspx?#ItemSrv.ashx|SeasonId=57I&CollectionId=07H&ItemId=12"
    @helper = LuisaviaromaCom.new(@url)
  end

  test "it should find class from url" do
    assert MerchantHelper.send(:from_url, @url).kind_of?(LuisaviaromaCom)
  end

  test "it should monetize" do
  end

  test "it should canonize" do
  end

  test "it should process availability" do
  end

  test "it should parse specific availability" do
  end

  test "it should process price_shipping" do
    text = "Supplément de 5 €"
    @version[:price_shipping_text] = text
    @version = @helper.process_price_shipping(@version)
    assert_equal LuisaviaromaCom::DEFAULT_PRICE_SHIPPING, @version[:price_shipping_text]

    @version[:price_shipping_text] = nil
    @version = @helper.process_price_shipping(@version)
    assert_equal LuisaviaromaCom::DEFAULT_PRICE_SHIPPING, @version[:price_shipping_text]
  end

  test "it should process shipping_info" do
    text = "Délai de 5 jours"
    @version[:shipping_info] = text
    @version = @helper.process_shipping_info(@version)
    assert_equal LuisaviaromaCom::DEFAULT_SHIPPING_INFO, @version[:shipping_info]

    @version[:shipping_info] = ""
    @version = @helper.process_shipping_info(@version)
    assert_equal LuisaviaromaCom::DEFAULT_SHIPPING_INFO, @version[:shipping_info]
  end

  test "it should process image_url" do
    @version[:image_url] = "http://images.luisaviaroma.com/Big57I/07H/012_26efd1da-d067-4a0b-a075-af1964dedbd1.JPG"
    @version = @helper.process_image_url(@version)
    assert_equal "http://images.luisaviaroma.com/Zoom57I/07H/012_26efd1da-d067-4a0b-a075-af1964dedbd1.JPG", @version[:image_url]
  end

  test "it should process images" do
    @version[:images] = nil
    @version = @helper.process_images(@version)
    assert_nil @version[:images]

    @version[:images] = []
    @version = @helper.process_images(@version)
    assert_equal [], @version[:images]

    @version[:images] = ["http://images.luisaviaroma.com/Total57I/07H/012_fe8525c8-d6c2-49ff-9715-0bc6841a8bbe.JPG"]
    @version = @helper.process_images(@version)
    assert_equal ["http://images.luisaviaroma.com/Zoom57I/07H/012_fe8525c8-d6c2-49ff-9715-0bc6841a8bbe.JPG"], @version[:images]
  end
end
