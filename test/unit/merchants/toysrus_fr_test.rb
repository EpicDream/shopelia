# -*- encoding : utf-8 -*-
require 'test_helper'

class ToysrusFrTest < ActiveSupport::TestCase

  setup do
    @helper = ToysrusFr.new("http://www.toysrus.fr/product/index.jsp?productId=11621761")
  end

  test "it should monetize" do
    assert_equal "http://ad.zanox.com/ppc/?25465502C586468223&ulp=[[http://www.toysrus.fr/redirect_znx.jsp?url=http://www.toysrus.fr/product/index.jsp?productId=11621761&]]", @helper.monetize
  end

  test "it should canonize" do
    helper = ToysrusFr.new("http://www.toysrus.fr/product/index.jsp?productId=19508531&ab=TRUhome_cms3_promo_Dujardin_1000BornesPlanes")
    assert_equal "http://www.toysrus.fr/product/index.jsp?productId=19508531", helper.canonize
  end

  test "it should process shipping price" do
    version = @helper.process_shipping_price({})
    assert_equal "7.20", version[:price_shipping_text]
  end
end