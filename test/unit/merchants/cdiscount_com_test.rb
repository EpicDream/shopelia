# -*- encoding : utf-8 -*-
require 'test_helper'

class CdiscountComTest < ActiveSupport::TestCase

  setup do
    @version = {}
    @url = "http://www.cdiscount.com/electromenager/aspirateur-nettoyeur-vapeur/dirt-devil-m2828-3/f-110140405-dirtm28283.html"
    @helper = CdiscountCom.new(@url)
  end

  test "it should find class from url" do
    assert MerchantHelper.send(:from_url, @url).kind_of?(CdiscountCom)
  end

  test "it should monetize" do
    assert_equal "http://pdt.tradedoubler.com/click?a(2238732)p(72222)prod(765856165)ttid(5)url(http%3A%2F%2Fwww.cdiscount.com%2Felectromenager%2Faspirateur-nettoyeur-vapeur%2Fdirt-devil-m2828-3%2Ff-110140405-dirtm28283.html)", @helper.monetize
  end

  test "it should process availability" do
    @version[:availability_text] = "En stock"
    @version[:shipping_info] = "Sous 3 à 4 jours"
    @version = @helper.process_availability(@version)
    assert_equal "En stock", @version[:availability_text]

    @version[:shipping_info] = "Disponible sous 6h en magasin"
    @version = @helper.process_availability(@version)
    assert_equal MerchantHelper::UNAVAILABLE, @version[:availability_text]
  end

  test "it should canonize" do
    assert_equal "http://www.cdiscount.com/dp.asp?sku=81367657", CdiscountCom.new("http://www.cdiscount.com/dp.asp?sku=81367657").canonize
    assert_equal "http://www.cdiscount.com/dp.asp?sku=JAMO_S606HGB", CdiscountCom.new("http://www.cdiscount.com/dp.asp?sku=JAMO_S606HGB").canonize
  end

  test "it should process price shipping" do
    @version[:price_shipping_text] = ""
    @version = @helper.process_price_shipping(@version)
    assert_equal CdiscountCom::DEFAULT_PRICE_SHIPPING, @version[:price_shipping_text]

    @version[:price_shipping_text] = "4,90 €"
    @version = @helper.process_price_shipping(@version)
    assert_equal "4,90 €", @version[:price_shipping_text]
  end

  test "it should process image_url ajaxLoader" do
    @version[:image_url] = "http://i2.cdscdn.com/pdt2/0/8/k/3/300x300/phil50pfl5008k/rw/philips-50pfl5008k-tv-led-3d-smart-tv-ambilight.jpg"
    @version = @helper.process_image_url(@version)
    assert_equal "http://i2.cdscdn.com/pdt2/0/8/k/3/700x700/phil50pfl5008k/rw/philips-50pfl5008k-tv-led-3d-smart-tv-ambilight.jpg", @version[:image_url]
  end

  test "it should process images" do
    @version[:images] = nil
    @version = @helper.process_images(@version)
    assert_nil @version[:images]

    @version[:images] = []
    @version = @helper.process_images(@version)
    assert_equal [], @version[:images]

    @version[:images] = ["http://i2.cdscdn.com/pdt2/0/8/k/1/040x040/phil50pfl5008k/rw/philips-50pfl5008k-tv-led-3d-smart-tv-ambilight.jpg"]
    @version = @helper.process_images(@version)
    assert_equal ["http://i2.cdscdn.com/pdt2/0/8/k/1/700x700/phil50pfl5008k/rw/philips-50pfl5008k-tv-led-3d-smart-tv-ambilight.jpg"], @version[:images]
  end
end
