# -*- encoding : utf-8 -*-
require 'test_helper'

class MerchantHelperTest < ActiveSupport::TestCase

  setup do
    @version = {}
  end

  test "it should process image_url" do 
    @version[:image_url] = "//amazon.fr/image.jpg"
    @version = MerchantHelper.process_version("http://www.amazon.fr", @version)

    assert_equal "http://amazon.fr/image.jpg", @version[:image_url]
  end
end