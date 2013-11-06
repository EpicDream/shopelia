# -*- encoding : utf-8 -*-
require 'test_helper'

class CarrefourFrTest < ActiveSupport::TestCase

  setup do
    @version = {}
    @url = "http://online.carrefour.fr/electromenager-multimedia/hp/cartouche-encre-n-342-couleur_a00000318_frfr.html"
    @helper = CarrefourFr.new(@url)
  end

  test "it should canonize" do
    assert_equal "http://online.carrefour.fr/electromenager-multimedia/hp/cartouche-encre-n-342-couleur_a00000318_frfr.html", @helper.canonize
  end

  test "it should process availability" do
    @version[:availability_text] = "En cours de réapprovisionnement"
    @version = @helper.process_availability(@version)
    assert_equal "En cours de réapprovisionnement", @version[:availability_text]

    @version[:availability_text] = ""
    @version = @helper.process_availability(@version)
    assert_equal MerchantHelper::AVAILABLE, @version[:availability_text]
  end

  test "it should process_price_shipping" do
    @version[:price_shipping_text] = "livraison gratuite"
    @version = @helper.process_price_shipping(@version)
    assert_equal "livraison gratuite", @version[:price_shipping_text]

    @version[:price_shipping_text] = ""
    @version = @helper.process_price_shipping(@version)
    assert_equal CarrefourFr::DEFAULT_PRICE_SHIPPING, @version[:price_shipping_text]
  end

  test "it should process_shipping_info" do
    @version[:shipping_info] = "Délai de 2 semaines."
    @version = @helper.process_shipping_info(@version)
    assert_equal "Délai de 2 semaines.", @version[:shipping_info]

    @version[:shipping_info] = ""
    @version = @helper.process_shipping_info(@version)
    assert_equal CarrefourFr::DEFAULT_SHIPPING_INFO, @version[:shipping_info]
  end
end