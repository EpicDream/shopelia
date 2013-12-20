# -*- encoding : utf-8 -*-
require 'test_helper'

class ZalandoFrTest < ActiveSupport::TestCase

  setup do
    @version = {}
    @url = "http://www.zalando.fr/desigual-winter-flowers-sac-a-main-multicolore-de151a05p-704.html"
    @helper = ZalandoFr.new(@url)
  end

  test "it should find class from url" do
    assert MerchantHelper.send(:from_url, @url).kind_of?(ZalandoFr)
  end

  test "it should parse specific availability" do
    assert_equal false, MerchantHelper.parse_availability("Vos modèles préférés", @url)[:avail]
    assert_equal false, MerchantHelper.parse_availability("Plus de 1 500 marques", @url)[:avail]
    assert_equal false, MerchantHelper.parse_availability("TOUS LES PRODUITS DE LA LEÇON DE STYLE:", @url)[:avail]
  end

  test "it should process price_shipping unless if present" do
    @version[:price_shipping_text] = "3,50 €"
    @version = @helper.process_price_shipping(@version)
    assert_equal "3,50 €", @version[:price_shipping_text]
  end

  test "it should process price_shipping if empty" do
    @version[:price_shipping_text] = ""
    @version = @helper.process_price_shipping(@version)
    assert_equal ZalandoFr::DEFAULT_PRICE_SHIPPING, @version[:price_shipping_text]
    assert_equal MerchantHelper::FREE_PRICE, @version[:price_shipping_text]
  end

end
