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
end
