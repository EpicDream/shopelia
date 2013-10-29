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

  test "it should process availability" do
    @version[:availability_text] = "En stock"
    @version = @helper.process_availability(@version)
    assert_equal "En stock", @version[:availability_text]
    
    @version[:availability_text] = "vos modeles preferes"
    @version = @helper.process_availability(@version)
    assert_equal MerchantHelper::UNAVAILABLE, @version[:availability_text]
  end
end
