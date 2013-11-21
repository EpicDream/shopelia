# -*- encoding : utf-8 -*-
require 'test_helper'

class SephoraFrTest < ActiveSupport::TestCase

  setup do
    @version = {}
    @url = "http://www.sephora.fr/Maquillage/Teint/Fonds-de-Teint/Naked-Skin-Weightless-Ultra-Definition-Liquid-Makeup-Fond-de-Teint-Liquide/P1064003;jsessionid=0357A78FD68BB001852051897A0C0334.wfr1g"
    @helper = SephoraFr.new(@url)
  end

  test "it should find class from url" do
    assert MerchantHelper.send(:from_url, @url).kind_of?(SephoraFr)
  end
  
  test "it should process_price_shipping" do
    @version[:price_shipping_text] = "livraison gratuite"
    @version = @helper.process_price_shipping(@version)
    assert_equal "livraison gratuite", @version[:price_shipping_text]

    @version[:price_text] = "5.59 €"
    @version[:price_shipping_text] = ""
    @version = @helper.process_price_shipping(@version)
    assert_equal SephoraFr::DEFAULT_PRICE_SHIPPING, @version[:price_shipping_text]

    @version[:price_text] = "60.0 €"
    @version[:price_shipping_text] = ""
    @version = @helper.process_price_shipping(@version)
    assert_equal MerchantHelper::FREE_PRICE, @version[:price_shipping_text]
  end

  test "it should process_shipping_info" do
    @version[:shipping_info] = "Délai de 2 semaines."
    @version = @helper.process_shipping_info(@version)
    assert_equal "Délai de 2 semaines.", @version[:shipping_info]

    @version[:shipping_info] = ""
    @version = @helper.process_shipping_info(@version)
    assert_equal SephoraFr::DEFAULT_SHIPPING_INFO, @version[:shipping_info]
  end
end
