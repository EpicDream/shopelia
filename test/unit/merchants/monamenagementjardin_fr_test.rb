# -*- encoding : utf-8 -*-
require 'test_helper'

class MonamenagementjardinFrTest < ActiveSupport::TestCase

  setup do
    @version = {}
    @url = "http://www.monamenagementjardin.fr/stabilisateur-gravier-polypropylene.html"
    @helper = MonamenagementjardinFr.new(@url)
  end

  test "it should find class from url" do
    assert MerchantHelper.send(:from_url, @url).kind_of?(MonamenagementjardinFr)
  end

  test "it should process availability" do
    @version[:availability_text] = ""
    @version = @helper.process_availability(@version)
    assert_equal "En stock", @version[:availability_text]

    @version[:availability_text] = "Produit en rupture"
    @version = @helper.process_availability(@version)
    assert_equal "Produit en rupture", @version[:availability_text]
  end

  test "it should process price shipping" do
    @version = @helper.process_shipping_price(@version)
    assert_equal "LIVRAISON GRATUITE", @version[:price_shipping_text]
  end
end