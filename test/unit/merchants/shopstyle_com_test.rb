# -*- encoding : utf-8 -*-
require 'test_helper'

class ShopstyleComTest < ActiveSupport::TestCase

  test "it should canonize" do
    urls = [
      { in: 'http://api.shopstyle.com/action/apiVisitRetailer?pid=puid14728235&url=http://www.barneys.com/on/demandware.store/Sites-BNY-Site/default/Product-Show?pid=502921664',
        out: 'http://www.barneys.com/on/demandware.store/Sites-BNY-Site/default/Product-Show?pid=502921664'
      }
    ]
    urls.each do |url|
      assert_equal(url[:out], ShopstyleCom.new(url[:in]).canonize)
    end
  end
end