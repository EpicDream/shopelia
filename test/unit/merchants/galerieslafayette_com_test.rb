# -*- encoding : utf-8 -*-
require 'test_helper'

class GalerieslafayetteComTest < ActiveSupport::TestCase

  setup do
    @version = {}
    @url = "http://www.galerieslafayette.com/a/lego+60002+city+le+camion+de+pompier-lego/300400729085?ectrans=1&utm="
    @helper = GalerieslafayetteCom.new(@url)
  end

  test "it should find class from url" do
    assert MerchantHelper.send(:from_url, @url).kind_of?(GalerieslafayetteCom)
  end

  test "it should canonize" do
    assert_equal "http://www.galerieslafayette.com/a/300400729085", GalerieslafayetteCom.new(@url).canonize
    url = "http://www.galerieslafayette.com/p/hasbro+-+littlest+petshop+-+le+cirque-hasbro/46622379/306"
    assert_equal "http://www.galerieslafayette.com/p/46622379/306", GalerieslafayetteCom.new(url).canonize
  end

  test "it should process availability" do
    text = "Indisponible"
    @version[:availability_text] = text
    @version = @helper.process_availability(@version)
    assert_equal text, @version[:availability_text]

    @version[:availability_text] = ""
    @version = @helper.process_availability(@version)
    assert_equal MerchantHelper::AVAILABLE, @version[:availability_text]
  end

  test "it should parse specific availability" do
  end

  test "it should process price_shipping if empty" do
    @version[:price_shipping_text] = ""
    @version = @helper.process_price_shipping(@version)
    assert_equal GalerieslafayetteCom::DEFAULT_PRICE_SHIPPING, @version[:price_shipping_text]
  end

  test "it should process price_shipping if greater than limit" do
    @version[:price_text] = sprintf("%.2f €", GalerieslafayetteCom::FREE_SHIPPING_LIMIT-1)
    @version = @helper.process_price_shipping(@version)
    assert_equal GalerieslafayetteCom::DEFAULT_PRICE_SHIPPING, @version[:price_shipping_text]

    @version[:price_text] = sprintf("%.2f €", GalerieslafayetteCom::FREE_SHIPPING_LIMIT)
    @version = @helper.process_price_shipping(@version)
    assert_equal MerchantHelper::FREE_PRICE, @version[:price_shipping_text]
  end

  test "it should process shipping_info" do
    text = "Délai de 5 jours"
    @version[:shipping_info] = text
    @version = @helper.process_shipping_info(@version)
    assert_equal text, @version[:shipping_info]

    @version[:shipping_info] = ""
    @version = @helper.process_shipping_info(@version)
    assert_equal GalerieslafayetteCom::DEFAULT_SHIPPING_INFO, @version[:shipping_info]
  end
end
