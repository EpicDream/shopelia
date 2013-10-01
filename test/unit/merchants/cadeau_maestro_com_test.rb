# -*- encoding : utf-8 -*-
require 'test_helper'

class CadeauMaestroComTest < ActiveSupport::TestCase

  setup do
    @version = {}
    @helper = CadeauMaestroCom.new("http://www.cadeau-maestro.com/196-paillassons-originaux/1706-paillasson-slide-to-unlock-8430306253466.html")
  end

  test "it should canonize (1)" do
    helper = CadeauMaestroCom.new "http://www.cadeau-maestro.com/196-paillassons-originaux/1706-paillasson-slide-to-unlock-8430306253466.html"
    url = helper.canonize

    assert_equal "http://www.cadeau-maestro.com/196/1706-8430306253466.html", url
  end

  test "it should canonize (2)" do
    helper = CadeauMaestroCom.new "http://www.cadeau-maestro.com/181-horloges-originales/27-horloge-a-eau.html"
    url = helper.canonize

    assert_equal "http://www.cadeau-maestro.com/181/27.html", url
  end

  test "it should canonize (3)" do
    helper = CadeauMaestroCom.new "http://www.cadeau-maestro.com/92-cadeau-fumeur"
    url = helper.canonize

    assert_equal "http://www.cadeau-maestro.com/92-cadeau-fumeur", url
  end

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

    assert_equal "4.50 (à titre indicatif)", @version[:price_shipping_text]
  end
end