# -*- encoding : utf-8 -*-
require 'test_helper'

class TopgeekNetTest < ActiveSupport::TestCase

  setup do
    @version = {}
    @url = "http://www.topgeek.net/fr/space-invaders/332-decapsuleur-space-invaders-5060224471180.html"
    @helper = TopgeekNet.new(@url)
  end

  test "it should find class from url" do
    assert MerchantHelper.send(:from_url, @url).kind_of?(TopgeekNet)
  end

  test "it should canonize" do
    urls = {
      @url => "http://www.topgeek.net/332-5060224471180.html",
      "http://www.topgeek.net/fr/53-mugs-et-tasses" => "http://www.topgeek.net/fr/53-mugs-et-tasses",
    }
    for url, result in urls
      assert_equal result, TopgeekNet.new(url).canonize
    end
  end

  test "it should process price shipping" do
    @version[:price_shipping_text] = ""
    @version = @helper.process_shipping_price(@version)

    assert_equal "3,90 € (à titre indicatif)", @version[:price_shipping_text]
  end

  test "it should process shipping info" do
    @version[:shipping_info] = ""
    @version = @helper.process_shipping_info(@version)

    assert_equal "Livraison SoColissimo.", @version[:shipping_info]
  end
end