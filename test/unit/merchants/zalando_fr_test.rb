# -*- encoding : utf-8 -*-
require 'test_helper'

class ZalandoFrTest < ActiveSupport::TestCase

  setup do
    @version = {}
    @url = "http://www.zalando.fr/desigual-winter-flowers-sac-a-main-multicolore-de151a05p-704.html"
    @helper = ZalandoFr.new(@url)
  end

  test "it should find class from url" do
    assert MerchantHelper.send(:from_url, @url).kind_of?(ZalandoFr)
  end

  test "it should parse specific availability" do
    assert_equal false, MerchantHelper.parse_availability("Vos modèles préférés", @url)[:avail]
  end
end
