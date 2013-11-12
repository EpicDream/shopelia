# -*- encoding : utf-8 -*-
require 'test_helper'

class BrandalleyFrTest < ActiveSupport::TestCase

  setup do
    @version = {}
    @url = "http://eulerian.brandalley.fr/dynclick/brandalley-fr/?etf-publisher=tradedoubler&etf-name=Flux-TradeDoubler-Lengow&etf-prdref=1177913&eseg-name=idaffilie&eseg-item=[TD_AFFILIATE_ID]&eurl=http://www.brandalley.fr/fiche-Produit/Rayon-1177913&Origine=[REMPLACE_CODE_ORIGINE]&utm_medium=Affiliation&utm_source=tradedoubler&utm_campaign=Flux-TradeDoubler-Lengow&LGWCODE=1177913;16066;613"
    @helper = BrandalleyFr.new(@url)
  end

  test "it should find class from url" do
    assert MerchantHelper.send(:from_url, @url).kind_of?(BrandalleyFr)
  end

  test "it should canonize" do
    assert_equal "http://www.brandalley.fr/fiche-Produit/Rayon-1177913", @helper.canonize
  end

  test "it should process availability" do
    text = "Indisponible"
    @version[:availability_text] = text
    @version = @helper.process_availability(@version)
    assert_equal text, @version[:availability_text]

    @version[:availability_text] = "taille selectionnee : 38 - plus que 3"
    @version = @helper.process_availability(@version)
    assert_equal "plus que 3", @version[:availability_text]

    @version[:availability_text] = "taille unique - plus que 4"
    @version = @helper.process_availability(@version)
    assert_equal "plus que 4", @version[:availability_text]
  end

  test "it should process price_shipping if empty" do
    @version[:price_shipping_text] = ""
    @version = @helper.process_price_shipping(@version)
    assert_equal BrandalleyFr::DEFAULT_PRICE_SHIPPING, @version[:price_shipping_text]
  end

  test "it should process price_shipping if greater than limit" do
    @version[:price_text] = sprintf("%.2f €", BrandalleyFr::FREE_SHIPPING_LIMIT-1)
    @version = @helper.process_price_shipping(@version)
    assert_equal BrandalleyFr::DEFAULT_PRICE_SHIPPING, @version[:price_shipping_text]

    @version[:price_text] = sprintf("%.2f €", BrandalleyFr::FREE_SHIPPING_LIMIT)
    @version = @helper.process_price_shipping(@version)
    assert_equal MerchantHelper::FREE_PRICE, @version[:price_shipping_text]
  end
end
