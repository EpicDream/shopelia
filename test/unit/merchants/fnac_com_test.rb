# -*- encoding : utf-8 -*-
require 'test_helper'

class FnacComTest < ActiveSupport::TestCase

  setup do
    @version = {}
    @url = "http://www.fnac.com/Tous-les-Enregistreurs/Enregistreur-DVD-Enregistreur-Blu-ray/nsh180760/w-4#bl=MMtvh"
    @helper = FnacCom.new(@url)
  end

  test "it should find class from url" do
    assert MerchantHelper.send(:from_url, @url).kind_of?(FnacCom)
  end

  test "it should monetize" do
    assert_equal "http://ad.zanox.com/ppc/?25134383C1552684717T&ULP=[[www.fnac.com%2FTous-les-Enregistreurs%2FEnregistreur-DVD-Enregistreur-Blu-ray%2Fnsh180760%2Fw-4%23bl%3DMMtvh]]", @helper.monetize
  end

  test "it should canonize" do
    assert_equal "http://www.fnac.com/Tous-les-Enregistreurs/Enregistreur-DVD-Enregistreur-Blu-ray/nsh180760/w-4", @helper.canonize
  end

  test "it should parse specific availability" do
    assert_equal false, MerchantHelper.parse_availability("Allez vers la version simple", @url)[:avail]
  end

  test "it should process_price_shipping" do
    @version[:price_shipping_text] = "Livraison gratuite (?)"
    @version = @helper.process_price_shipping(@version)
    assert_equal "Livraison gratuite (?)", @version[:price_shipping_text]

    @version[:price_shipping_text] = "Livraison rapide offerte pour les produits vendus et expédiés par Fnac.com uniquement (Hors MarketPlace et Tirage Photo)."
    @version = @helper.process_price_shipping(@version)
    assert_equal MerchantHelper::FREE_PRICE, @version[:price_shipping_text]
  end

  test "it should process_shipping_info" do
    @version[:shipping_info] = "Livraison en 2 jours ouvrés"
    @version[:price_shipping_text] = "3 € 50"
    @version = @helper.process_shipping_info(@version)
    assert_equal "Livraison en 2 jours ouvrés", @version[:shipping_info]

    @version[:shipping_info] = "Livraison en 2 jours ouvrés"
    @version[:price_shipping_text] = ""
    @version = @helper.process_shipping_info(@version)
    assert_equal "Livraison en 2 jours ouvrés", @version[:shipping_info]

    @version[:shipping_info] = ""
    @version[:price_shipping_text] = "3 € 50"
    @version = @helper.process_shipping_info(@version)
    assert_equal FnacCom::DEFAULT_SHIPPING_INFO, @version[:shipping_info]

    @version[:shipping_info] = ""
    @version[:price_shipping_text] = ""
    @version = @helper.process_shipping_info(@version)
    assert_equal FnacCom::DEFAULT_SHIPPING_INFO_PLUS_PRICE, @version[:shipping_info]
  end
end