# -*- encoding : utf-8 -*-
require 'test_helper'

class TopshopComTest < ActiveSupport::TestCase

  setup do
    @version = {}
    @url = "http://fr.topshop.com/fr/tsfr/produit/v%C3%AAtements-415222/tops-415238/chemise-%C3%A0-pois-camouflage-2415275?bi=1&ps=200"
    @helper = TopshopCom.new(@url)
  end

  test "it should find class from url" do
    assert MerchantHelper.send(:from_url, @url).kind_of?(TopshopCom)
  end

  test "it should monetize" do
  end

  test "it should canonize" do
    urls = [
      { in: @url,
        out: "http://fr.topshop.com/fr/tsfr/produit/chemise-%C3%A0-pois-camouflage-2415275" },
    ]
    urls.each do |url|
      assert_equal(url[:out], TopshopCom.new(url[:in]).canonize)
    end
  end

  test "it should process availability" do
    text = "Produit indisponible actuellement"
    @version[:availability_text] = text
    @version = @helper.process_availability(@version)
    assert_equal text, @version[:availability_text]

    @version[:availability_text] = ""
    @version = @helper.process_availability(@version)
    assert_equal MerchantHelper::AVAILABLE, @version[:availability_text]
  end

  test "it should parse specific availability" do
    assert_equal false, MerchantHelper.parse_availability("Articles à l'écran 1 - 5 de 5", @url)[:avail]
  end

  test "it should process price_shipping" do
    text = "10 €"
    @version[:price_shipping_text] = text
    @version = @helper.process_price_shipping(@version)
    assert_equal text, @version[:price_shipping_text]

    @version[:price_shipping_text] = ""
    @version = @helper.process_price_shipping(@version)
    assert_equal TopshopCom::DEFAULT_PRICE_SHIPPING, @version[:price_shipping_text]
  end

  test "it should process shipping_info" do
    text = "Délai de 5 jours"
    @version[:shipping_info] = text
    @version = @helper.process_shipping_info(@version)
    assert_equal text, @version[:shipping_info]

    @version[:shipping_info] = ""
    @version = @helper.process_shipping_info(@version)
    assert_equal TopshopCom::DEFAULT_SHIPPING_INFO, @version[:shipping_info]
  end

  test "it should process image_url" do
    @version[:image_url] = "http://fr.topshop.com/wcsstore/TopShopFR/images/catalog/23I37EGRY_3_small.jpg"
    @version = @helper.process_image_url(@version)
    assert_equal "http://fr.topshop.com/wcsstore/TopShopFR/images/catalog/23I37EGRY_3_large.jpg", @version[:image_url]
  end

  test "it should process images" do
    @version[:images] = nil
    @version = @helper.process_images(@version)
    assert_nil @version[:images]

    @version[:images] = []
    @version = @helper.process_images(@version)
    assert_equal [], @version[:images]

    @version[:images] = ["http://fr.topshop.com/wcsstore/TopShopFR/images/catalog/23I37EGRY_2_normal.jpg"]
    @version = @helper.process_images(@version)
    assert_equal ["http://fr.topshop.com/wcsstore/TopShopFR/images/catalog/23I37EGRY_2_large.jpg"], @version[:images]
  end
end
