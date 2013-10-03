# -*- encoding : utf-8 -*-
require 'test_helper'

class LedindonComTest < ActiveSupport::TestCase

  setup do
    @version = {}
    @url = "http://www.ledindon.com/decoration-interieure/8938-mr-casserole.php"
    @helper = LedindonCom.new(@url)
  end

  test "it should find class from url" do
    assert MerchantHelper.send(:from_url, @url).kind_of?(LedindonCom)
  end

  test "it should process price shipping" do
    @version[:price_shipping_text] = ""
    @version = @helper.process_shipping_price(@version)
    assert_equal "6,50 € (à titre indicatif)", @version[:price_shipping_text]
  end

  test "it should process shipping info" do
    @version[:shipping_info] = ""
    @version = @helper.process_shipping_info(@version)
    assert_equal "Livraison Colissimo 48h. ", @version[:shipping_info]

    @version[:shipping_info] = "En stock (Expédié sous 24h)"
    @version = @helper.process_shipping_info(@version)
    assert_equal "Livraison Colissimo 48h. En stock (Expédié sous 24h)", @version[:shipping_info]
  end
end