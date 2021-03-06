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

    @version[:availability_text] = "TAILLE UNIQUE - DISPONIBLE"
    @version = @helper.process_availability(@version)
    assert_equal "DISPONIBLE", @version[:availability_text]
  end

  test "it should parse specific availability" do
    assert_equal true, MerchantHelper.parse_availability("plus que 2", @url)[:avail]
    assert_equal false, MerchantHelper.parse_availability("1829 article(s)\nHomme prêt-à-porter t-shirts & polos t-shirts manches courtes", @url)[:avail]
    assert_equal false, MerchantHelper.parse_availability("ACCÉDER À LA BOUTIQUE", @url)[:avail]

    str = "Taille sélectionnée : M - Disponible"
    str = @helper.process_availability({availability_text: str})[:availability_text]
    assert_equal true, MerchantHelper.parse_availability(str, @url)[:avail]
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

  test "it should process option" do
    @version[:option1] = {"style" => "background: FFFFFF;", "text" => "Blanc", "src" => ""}
    @version = @helper.process_options(@version)
    assert_equal "Blanc", @version[:option1]["text"]

    @version[:option1] = {"style" => "background: FFFFFF;", "text" => "", "src" => @url}
    @version = @helper.process_options(@version)
    assert_equal "", @version[:option1]["text"]

    @version[:option1] = {"style" => "background: FFFFFF;", "text" => "", "src" => ""}
    @version = @helper.process_options(@version)
    assert_equal "FFFFFF", @version[:option1]["text"]

    @version[:option1] = {"style" => "background: #F60409;", "text" => "", "src" => ""}
    @version = @helper.process_options(@version)
    assert_equal "#F60409", @version[:option1]["text"]
    @version[:option1] = {"style" => "background-color:#c6865a;margin:2px;width:10px;height:12px;", "text" => "", "src" => ""}
    @version = @helper.process_options(@version)
    assert_equal "#c6865a", @version[:option1]["text"]
  end
end
