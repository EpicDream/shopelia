# -*- encoding : utf-8 -*-
require 'test_helper'

class CadeauMaestroComTest < ActiveSupport::TestCase

  setup do
    @version = {}
    @url = "http://www.cadeau-maestro.com/196-paillassons-originaux/1706-paillasson-slide-to-unlock-8430306253466.html"
    @helper = CadeauMaestroCom.new(@url)
  end

  test "it should find class from url" do
    assert MerchantHelper.send(:from_url, @url).kind_of?(CadeauMaestroCom)
  end

  # test "it should canonize" do
  #   urls = {
  #     "http://www.cadeau-maestro.com/196-paillassons-originaux/1706-paillasson-slide-to-unlock-8430306253466.html" =>
  #       "http://www.cadeau-maestro.com/196/1706-8430306253466.html",
  #     "http://www.cadeau-maestro.com/181-horloges-originales/27-horloge-a-eau.html" =>
  #       "http://www.cadeau-maestro.com/181/27.html",
  #     "http://www.cadeau-maestro.com/92-cadeau-fumeur" =>
  #       "http://www.cadeau-maestro.com/92-cadeau-fumeur",
  #     "http://www.cadeau-maestro.com/279/1683-5546902001479.html" =>
  #       "http://www.cadeau-maestro.com/279/1683-5546902001479.html",
  #     "http://www.cadeau-maestro.com/196/1706-paillasson-slide-to-unlock-8430306253466.html" =>
  #       "http://www.cadeau-maestro.com/196/1706-8430306253466.html",
  #     "http://www.cadeau-maestro.com/196-paillassons-originaux/1706-8430306253466.html" =>
  #       "http://www.cadeau-maestro.com/196/1706-8430306253466.html",
  #   }
  #   for url, result in urls
  #     assert_equal result, CadeauMaestroCom.new(url).canonize
  #   end
  # end

  test "it should process availability (1)" do
    @version[:availability_text] = "Ce produit n'est plus en stock"
    @version = @helper.process_availability(@version)

    assert_equal "Ce produit n'est plus en stock", @version[:availability_text]
  end

  test "it should process availability (2)" do
    @version[:availability_text] = ""
    @version = @helper.process_availability(@version)

    assert_equal "En stock", @version[:availability_text]
  end

  test "it should process price shipping" do
    @version[:price_shipping_text] = ""
    @version = @helper.process_shipping_price(@version)

    assert_equal "4,50 € (à titre indicatif)", @version[:price_shipping_text]
  end

  test "it should parse specific availability" do
    assert_equal false, MerchantHelper.parse_availability("Découvrez nos 40 idées cadeaux accessoires téléphone", @url)[:avail]
  end
end