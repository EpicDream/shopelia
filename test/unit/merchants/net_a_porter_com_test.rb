# -*- encoding : utf-8 -*-
require 'test_helper'

class NetAPorterComTest < ActiveSupport::TestCase

  setup do
    @version = {}
    @url = "http://www.net-a-porter.com/product/320164"
    @helper = NetAPorterCom.new(@url)
  end

  test "it should find class from url" do
    assert MerchantHelper.send(:from_url, @url).kind_of?(NetAPorterCom)
  end

  test "it should monetize" do
  end

  test "it should canonize" do
  end

  test "it should process availability" do
    text = "Produit indisponible actuellement"
    @version[:availability_text] = text
    @version = @helper.process_availability(@version)
    assert_equal text, @version[:availability_text]

    # @version[:availability_text] = ""
    # @version = @helper.process_availability(@version)
    # assert_equal MerchantHelper::AVAILABLE, @version[:availability_text]
  end

  test "it should parse specific availability" do
    assert_equal false, MerchantHelper.parse_availability("88 Résultats", @url)[:avail]
  end

  test "it should process price_shipping" do
    text = "Supplément de 5 €"
    @version[:price_shipping_text] = text
    @version = @helper.process_price_shipping(@version)
    assert_equal text, @version[:price_shipping_text]

    @version[:price_shipping_text] = nil
    @version = @helper.process_price_shipping(@version)
    assert_equal NetAPorterCom::DEFAULT_PRICE_SHIPPING, @version[:price_shipping_text]
  end

  test "it should process shipping_info" do
    text = "Délai de 5 jours"
    @version[:shipping_info] = text
    @version = @helper.process_shipping_info(@version)
    assert_equal text + ". " + NetAPorterCom::DEFAULT_SHIPPING_INFO, @version[:shipping_info]

    @version[:shipping_info] = ""
    @version = @helper.process_shipping_info(@version)
    assert_equal NetAPorterCom::DEFAULT_SHIPPING_INFO, @version[:shipping_info]
  end

  test "it should process images" do
    @version[:images] = nil
    @version = @helper.process_images(@version)
    assert_nil @version[:images]

    @version[:images] = []
    @version = @helper.process_images(@version)
    assert_equal [], @version[:images]

    @version[:images] = ["http://cache.net-a-porter.com/images/products/320164/320164_in_sl.jpg"]
    @version = @helper.process_images(@version)
    assert_equal ["http://cache.net-a-porter.com/images/products/320164/320164_in_xl.jpg"], @version[:images]
  end
end
