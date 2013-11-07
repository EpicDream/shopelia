# -*- encoding : utf-8 -*-
require 'test_helper'

class SuissesFrTest < ActiveSupport::TestCase

  setup do
    @version = {}
    @url = "http://www.3suisses.fr/femme/vetements-mode/chaussures/ballerines-tennis-ruban-satin-femme-R20001364?fac=e40&typObj=1&R=20001364000040000&isPresol=true"
    @helper = SuissesFr.new(@url)
  end

  test "it should canonize" do
    assert_equal "http://www.3suisses.fr/ballerines-tennis-ruban-satin-femme-R20001364", @helper.canonize
  end

  test "it should process price_strikeout" do
    @version[:price_strikeout_text] = "3 € 90"
    @version = @helper.process_price_strikeout(@version)
    assert_equal "3 € 90", @version[:price_strikeout_text]

    @version[:price_strikeout_text] = "€"
    @version = @helper.process_price_strikeout(@version)
    assert_nil @version[:price_strikeout_text]
  end

  test "it should process_price_shipping" do
    @version[:price_shipping_text] = "livraison gratuite"
    @version = @helper.process_price_shipping(@version)
    assert_equal "livraison gratuite", @version[:price_shipping_text]

    @version[:price_shipping_text] = ""
    @version = @helper.process_price_shipping(@version)
    assert_equal SuissesFr::DEFAULT_PRICE_SHIPPING, @version[:price_shipping_text]
  end

  test "it should process_shipping_info default value" do
    @version[:shipping_info] = "Délai de 2 semaines."
    @version = @helper.process_shipping_info(@version)
    assert_equal "Délai de 2 semaines.", @version[:shipping_info]

    @version[:shipping_info] = ""
    @version = @helper.process_shipping_info(@version)
    assert_equal SuissesFr::DEFAULT_SHIPPING_INFO, @version[:shipping_info]
  end
end