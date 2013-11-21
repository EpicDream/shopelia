# -*- encoding : utf-8 -*-
require 'test_helper'

class ConforamaFrTest < ActiveSupport::TestCase

  setup do
    @version = {}
    @url = "http://www.conforama.fr/produit_far-juicy-ci_blender_507021_10001_10602_-2_148414_148441_635512"
    @helper = ConforamaFr.new(@url)
  end

  test "it should find class from url" do
    assert MerchantHelper.send(:from_url, @url).kind_of?(ConforamaFr)
  end

  test "it should set availability" do
    @version = @helper.process_availability(@version)
    assert_equal MerchantHelper::AVAILABLE, @version[:availability_text]
  end

  test "it should set shipping info" do
    @version = @helper.process_shipping_info(@version)
    assert_match /Conforama/, @version[:shipping_info]
  end

  test "it should process price_shipping if empty" do
    @version[:price_shipping_text] = ""
    @version = @helper.process_price_shipping(@version)
    assert_equal ConforamaFr::DEFAULT_PRICE_SHIPPING, @version[:price_shipping_text]
  end
end