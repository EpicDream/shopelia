# -*- encoding : utf-8 -*-
require 'test_helper'

class MycrazystuffComTest < ActiveSupport::TestCase

  setup do
    @version = {}
    @url = "http://mycrazystuff.com/gadget-bureau/3121-mini-ventilateur-a-poser.html"
    @helper = MycrazystuffCom.new(@url)
  end

  test "it should find class from url" do
    assert MerchantHelper.send(:from_url, @url).kind_of?(MycrazystuffCom)
  end

  test "it should process availability" do
    @version[:availability_text] = "Prochaine expéditionDemain à 12H00"
    @version = @helper.process_availability(@version)
    assert_equal "En stock", @version[:availability_text]

    @version[:availability_text] = ""
    @version = @helper.process_availability(@version)
    assert_equal "Non disponible", @version[:availability_text]
  end

  test "it should process price shipping" do
    @version[:price_shipping_text] = ""
    @version = @helper.process_shipping_price(@version)
    assert_equal "5,80 € (à titre indicatif)", @version[:price_shipping_text]
  end

  test "it should process shipping info" do
    @version[:shipping_info] = ""
    @version = @helper.process_shipping_info(@version)

    assert_equal "Livraison Colissimo.", @version[:shipping_info]
  end
end