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

  test "it should parse_rating" do
    array = [ "4", "4.0", "4/5", "4.0/5", "(4.0/5)",
      "4 / 5", "4.0 / 5", "(4.0 / 5)",
      "4.0 étoiles sur 5"]
    array.each do |str|
      assert_equal 4.0, MerchantHelper.parse_rating(str)
    end

    array = [ "3.5", "3.5/5", "(3.5/5)",
      "3.5 / 5", "(3.5 / 5)",
      "3.5 étoiles sur 5"]
    array.each do |str|
      assert_equal 3.5, MerchantHelper.parse_rating(str)
    end
  end
end