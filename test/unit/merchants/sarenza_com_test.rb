# -*- encoding : utf-8 -*-
require 'test_helper'

class SarenzaComTest < ActiveSupport::TestCase

  setup do
    @version = {}
    @url = "http://www.sarenza.com/spot-on-torroi-s2139-p0000087628"
    @helper = SarenzaCom.new(@url)
  end

  test "it should find class from url" do
    assert MerchantHelper.send(:from_url, @url).kind_of?(SarenzaCom)
  end

  test "it should monetize" do
  end

  test "it should canonize" do
    urls = []
    urls.each do |url|
      assert_equal(url[:out], SarenzaCom.new(url[:in]).canonize)
    end
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

  test "it should process availability for specific size" do
    @version[:availability_text] = "36 - Dernière paire !"
    @version = @helper.process_availability(@version)
    assert_equal "Dernière paire !", @version[:availability_text]
  end

  test "it should parse specific availability" do
    assert_equal false, MerchantHelper.parse_availability("6643 MODÈLES", @url)[:avail]
    assert_equal false, MerchantHelper.parse_availability("TOUTES LES MARQUES", @url)[:avail]
  end

  # test "it should process price_shipping unless if present" do
  #   @version[:price_shipping_text] = "3,50 €"
  #   @version = @helper.process_price_shipping(@version)
  #   assert_equal "3,50 €", @version[:price_shipping_text]
  # end

  test "it should process price_shipping if empty" do
    @version[:price_shipping_text] = ""
    @version = @helper.process_price_shipping(@version)
    assert_equal SarenzaCom::DEFAULT_PRICE_SHIPPING, @version[:price_shipping_text]
  end

  test "it should process shipping_info" do
    # text = "Délai de 5 jours"
    # @version[:shipping_info] = text
    # @version = @helper.process_shipping_info(@version)
    # assert_equal text, @version[:shipping_info]

    @version[:shipping_info] = ""
    @version = @helper.process_shipping_info(@version)
    assert_equal SarenzaCom::DEFAULT_SHIPPING_INFO, @version[:shipping_info]
  end

  test "it should process images" do
    @version[:images] = nil
    @version = @helper.process_images(@version)
    assert_nil @version[:images]

    @version[:images] = []
    @version = @helper.process_images(@version)
    assert_equal [], @version[:images]

    @version[:images] = ["http://azure.sarenza.net/static/_img/productsV4/0000061132/PI_0000061132_106887_09.jpg?201308250414"]
    @version = @helper.process_images(@version)
    assert_equal ["http://azure.sarenza.net/static/_img/productsV4/0000061132/HD_0000061132_106887_09.jpg?201308250414"], @version[:images]
  end
end
