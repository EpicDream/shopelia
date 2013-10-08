# -*- encoding : utf-8 -*-
require 'test_helper'

class PromessedefleursComTest < ActiveSupport::TestCase

  setup do
    @version = {}
    @url = "http://www.promessedefleurs.com/floraisons-automnales/colchiques/colchique-autumnale-album-p-326.html"
    @helper = PromessedefleursCom.new(@url)
  end

  test "it should find class from url" do
    assert MerchantHelper.send(:from_url, @url).kind_of?(PromessedefleursCom)
  end

  test "it should process price shipping" do
    @version = @helper.process_shipping_price(@version)
    assert_equal "6,90 € (à titre indicatif)", @version[:price_shipping_text]
  end
end