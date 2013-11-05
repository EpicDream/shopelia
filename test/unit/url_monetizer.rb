# -*- encoding : utf-8 -*-
require 'test_helper'

class UrlMonetizerTest < ActiveSupport::TestCase

  def test_monetizer
    url_monetizer = UrlMonetizer.new
    url_monetizer.set('http://www.shopelia-canonized.com', 'http://www.shopelia-original.com')
    result = url_monetizer.get('http://www.shopelia-canonized.com')
    assert_equal('http://www.shopelia-original.com', result)
  end
end

