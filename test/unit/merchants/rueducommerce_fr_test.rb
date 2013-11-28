# -*- encoding : utf-8 -*-
require 'test_helper'

class RueducommerceFrTest < ActiveSupport::TestCase

  setup do
    @version = {}
    @url = "http://www.rueducommerce.fr/m/ps/mpid:MP-0006DM7671064"
    @helper = RueducommerceFr.new(@url)
  end

  test "it should find class from url" do
    assert MerchantHelper.send(:from_url, @url).kind_of?(RueducommerceFr)
  end

  test "it should monetize" do
    assert_equal "http://ad.zanox.com/ppc/?25390102C2134048814&ulp=[[www.rueducommerce.fr%2Fm%2Fps%2Fmpid%3AMP-0006DM7671064]]", @helper.monetize
  end

  test "it should canonize" do
    assert_equal "http://www.rueducommerce.fr/m/ps/mpid:MP-0006DM7671064", @helper.canonize
    assert RueducommerceFr.new("http://www.rueducommerce.fr/bla").canonize.nil?
  end

  test "it should parse specific availability" do
    assert_equal false, MerchantHelper.parse_availability("(2409 articles)", @url)[:avail]
    assert_equal false, MerchantHelper.parse_availability("1180 références", @url)[:avail]
  end

  test "it should process availability" do
    @version[:availability_text] = ""
    @version[:price_text] = ""
    @version = @helper.process_availability(@version)
    assert_equal "", @version[:availability_text]

    @version[:availability_text] = "N'importe quoi"
    @version[:price_text] = ""
    @version = @helper.process_availability(@version)
    assert_equal "N'importe quoi", @version[:availability_text]

    @version[:availability_text] = "N'importe quoi"
    @version[:price_text] = "3,50 €"
    @version = @helper.process_availability(@version)
    assert_equal "N'importe quoi", @version[:availability_text]

    @version[:availability_text] = ""
    @version[:price_text] = "3,50 €"
    @version = @helper.process_availability(@version)
    assert_equal MerchantHelper::AVAILABLE, @version[:availability_text]
  end

  test "it should process shipping_info" do
    @version[:shipping_info] = "Dans un certain temps"
    @version = @helper.process_shipping_info(@version)
    assert_equal "Dans un certain temps", @version[:shipping_info]

    @version[:shipping_info] = ""
    @version = @helper.process_shipping_info(@version)
    assert_equal RueducommerceFr::DEFAULT_SHIPPING_INFO, @version[:shipping_info]
  end

  test "it should process price_shipping unless if present" do
    @version[:price_shipping_text] = "3,50 €"
    @version = @helper.process_price_shipping(@version)
    assert_equal "3,50 €", @version[:price_shipping_text]
  end

  test "it should process price_shipping if empty" do
    @version[:price_shipping_text] = ""
    @version = @helper.process_price_shipping(@version)
    assert_equal RueducommerceFr::DEFAULT_PRICE_SHIPPING, @version[:price_shipping_text]
  end

  test "it should process price_shipping if greater than limit" do
    @version[:price_shipping_text] = ""
    @version[:price_text] = sprintf("%.2f €", RueducommerceFr::FREE_SHIPPING_LIMIT-1)
    @version = @helper.process_price_shipping(@version)
    assert_equal RueducommerceFr::DEFAULT_PRICE_SHIPPING, @version[:price_shipping_text]

    @version[:price_shipping_text] = "5.17 €"
    @version[:price_text] = sprintf("%.2f €", RueducommerceFr::FREE_SHIPPING_LIMIT-1)
    @version = @helper.process_price_shipping(@version)
    assert_equal "5.17 €", @version[:price_shipping_text]

    @version[:price_shipping_text] = ""
    @version[:price_text] = sprintf("%.2f €", RueducommerceFr::FREE_SHIPPING_LIMIT)
    @version = @helper.process_price_shipping(@version)
    assert_equal MerchantHelper::FREE_PRICE, @version[:price_shipping_text]
  end

  test "it should process price_shipping a partir de" do
    @version[:price_shipping_text] = "So Colissimo (2 à 4 jours). - expédié sous 4 jours - à partir de 5,49 €"
    @version = @helper.process_price_shipping(@version)
    assert_equal "5,49 €", @version[:price_shipping_text]
  end

  test "it should process image_url ajaxLoader" do
    @version[:image_url] = "http://s1.static69.com/eros/img/ProductSheet/ajax-loader.gif"
    @version = @helper.process_image_url(@version)
    assert_nil @version[:image_url]

    @version[:image_url] = "http://s3.static69.com/m/image-offre/1/4/7/4/14740dfd07bcceae5eb12b418c44b3e1-500x500.jpg"
    @version = @helper.process_image_url(@version)
    assert_not_nil @version[:image_url]
  end

  test "it should process images" do
    @version[:images] = nil
    @version = @helper.process_images(@version)
    assert_nil @version[:images]

    @version[:images] = []
    @version = @helper.process_images(@version)
    assert_equal [], @version[:images]

    @version[:images] = ["http://s1.static69.com/mobile/images/produits/small/SGH-GALAXY-S-IV-16GO-FROST-WHITE.jpg"]
    @version = @helper.process_images(@version)
    assert_equal ["http://s1.static69.com/mobile/images/produits/big/SGH-GALAXY-S-IV-16GO-FROST-WHITE.jpg"], @version[:images]
  end
end
