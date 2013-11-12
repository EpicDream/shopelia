# -*- encoding : utf-8 -*-
require 'test_helper'

class ThekooplesComTest < ActiveSupport::TestCase

  setup do
    @version = {}
    @url = "http://www.thekooples.com/fr/homme/veste-1/veste-homme-8.html"
    @helper = ThekooplesCom.new(@url)
  end

  test "it should find class from url" do
    assert MerchantHelper.send(:from_url, @url).kind_of?(ThekooplesCom)
  end

  test "it should process availability" do
    @version[:availability_text] = "Ooops !!!"
    @version = @helper.process_availability(@version)
    assert_equal "Ooops !!!", @version[:availability_text]

    @version[:availability_text] = ""
    @version = @helper.process_availability(@version)
    assert_equal MerchantHelper::AVAILABLE, @version[:availability_text]
  end

  test "it should process_price_shipping" do
    @version[:price_shipping_text] = "livraison gratuite"
    @version = @helper.process_price_shipping(@version)
    assert_equal "livraison gratuite", @version[:price_shipping_text]

    @version[:price_shipping_text] = ""
    @version = @helper.process_price_shipping(@version)
    assert_equal ThekooplesCom::DEFAULT_PRICE_SHIPPING, @version[:price_shipping_text]
  end

  test "it should process_shipping_info" do
    @version[:shipping_info] = "Délai de 2 semaines."
    @version = @helper.process_shipping_info(@version)
    assert_equal "Délai de 2 semaines.", @version[:shipping_info]

    @version[:shipping_info] = ""
    @version = @helper.process_shipping_info(@version)
    assert_equal ThekooplesCom::DEFAULT_SHIPPING_INFO, @version[:shipping_info]
  end
end
