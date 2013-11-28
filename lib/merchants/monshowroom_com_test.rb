# -*- encoding : utf-8 -*-
require 'test_helper'

class MonshowroomComTest < ActiveSupport::TestCase

  setup do
    @version = {}
    @url = "http://www.monshowroom.com/fr/zoom/jack-and-jones/t-shirt-supersonic/145024"
    @helper = MonshowroomCom.new(@url)
  end

  test "it should find class from url" do
    assert MerchantHelper.send(:from_url, @url).kind_of?(MonshowroomCom)
  end

  test "it should monetize" do
  end

  test "it should canonize" do
    urls = []
    urls.each do |url|
      assert_equal(url[:out], MonshowroomCom.new(url[:in]).canonize)
    end
  end

  test "it should process availability" do
  end

  test "it should parse specific availability" do
  end

  test "it should process price_shipping" do
    text = "10 € 42"
    @version[:price_shipping_text] = text
    @version = @helper.process_price_shipping(@version)
    assert_equal text, @version[:price_shipping_text]

    @version[:price_shipping_text] = ""
    @version = @helper.process_price_shipping(@version)
    assert_equal MonshowroomCom::DEFAULT_PRICE_SHIPPING, @version[:price_shipping_text]
  end

  test "it should process shipping_info" do
    text = "Délai de 5 jours"
    @version[:shipping_info] = text
    @version = @helper.process_shipping_info(@version)
    assert_equal MonshowroomCom::DEFAULT_SHIPPING_INFO + text, @version[:shipping_info]

    @version[:shipping_info] = ""
    @version = @helper.process_shipping_info(@version)
    assert_equal MonshowroomCom::DEFAULT_SHIPPING_INFO, @version[:shipping_info]
  end

  test "it should process image_url" do
    @version[:image_url] = "http://static.monshowroom.com/img-collection/1/4/5/0/2/4/145024-01-g.jpg?d=2013-07-17_01:55:51"
    @version = @helper.process_image_url(@version)
    assert_equal "http://static.monshowroom.com/img-collection/1/4/5/0/2/4/145024-01-e.jpg", @version[:image_url]
  end

  test "it should process images" do
    @version[:images] = nil
    @version = @helper.process_images(@version)
    assert_nil @version[:images]

    @version[:images] = []
    @version = @helper.process_images(@version)
    assert_equal [], @version[:images]

    @version[:images] = ["http://static.monshowroom.com/img-collection/1/4/5/0/2/4/145024-01-d.jpg?d=2013-07-17_01:55:51"]
    @version = @helper.process_images(@version)
    assert_equal ["http://static.monshowroom.com/img-collection/1/4/5/0/2/4/145024-01-e.jpg"], @version[:images]
  end

  test "it should process option" do
    @version[:option1] = {"style" => "background: FFFFFF;", "text" => "Blanc", "src" => ""}
    @version = @helper.process_options(@version)
    assert_equal "Blanc", @version[:option1]["text"]

    @version[:option1] = {"style" => "background: FFFFFF;", "text" => "", "src" => @url}
    @version = @helper.process_options(@version)
    assert_equal "", @version[:option1]["text"]

    @version[:option1] = {"style" => "background: FFFFFF;", "text" => "", "src" => ""}
    @version = @helper.process_options(@version)
    assert_equal "FFFFFF", @version[:option1]["text"]

    @version[:option1] = {"style" => "background: #F60409;", "text" => "", "src" => ""}
    @version = @helper.process_options(@version)
    assert_equal "#F60409", @version[:option1]["text"]
    @version[:option1] = {"style" => "background-color:#c6865a;", "text" => "", "src" => ""}
    @version = @helper.process_options(@version)
    assert_equal "#c6865a", @version[:option1]["text"]
    @version[:option1] = {"style" => "padding-right:1px;border : 1px solid #E3E3E3; margin-top : 1px; height : 17px; width : 17px; background-color : #602f3b;border : 2px solid #000000;  margin-left : 4px;", "text" => "", "src" => ""}
    @version = @helper.process_options(@version)
    assert_equal "#602f3b", @version[:option1]["text"]
  end
end
