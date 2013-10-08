# -*- encoding : utf-8 -*-
require 'test_helper'

class NodshopComTest < ActiveSupport::TestCase

  setup do
    @version = {}
    @url = "http://www.nodshop.com/cadeau-cuisine/4598-glacons-grenade.html"
    @helper = NodshopCom.new(@url)
  end

  test "it should find class from url" do
    assert MerchantHelper.send(:from_url, @url).kind_of?(NodshopCom)
  end

  test "it should canonize" do
    urls = {
      @url => "http://www.nodshop.com/4598-glacons-grenade.html",
      "http://www.nodshop.com/4598-glacons-grenade.html" => "http://www.nodshop.com/4598-glacons-grenade.html",
      "http://www.nodshop.com/4443-cadeaux-enfant" => "http://www.nodshop.com/4443-cadeaux-enfant"
    }
    for url, result in urls
      assert_equal result, NodshopCom.new(url).canonize
    end
  end

  test "it should process price shipping" do
    @version[:price_shipping_text] = ""
    @version = @helper.process_shipping_price(@version)

    assert_equal "4,90 € (à titre indicatif)", @version[:price_shipping_text]
  end

  test "it should process shipping info" do
    @version[:shipping_info] = ""
    @version = @helper.process_shipping_info(@version)

    assert_equal "Livraison Colissimo 48h en France Metropolitaine.", @version[:shipping_info]
  end
end