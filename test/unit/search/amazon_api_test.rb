# -*- encoding : utf-8 -*-
require 'test_helper'

class Search::AmazonApiTest < ActiveSupport::TestCase
 
  test "it should request product by ean" do
    result = Search::AmazonApi.ean("5051889226314")
    assert_match /Game of Thrones/, result[:name]
    assert_match /images\-amazon/, result[:image_url]
    assert_match /B00605DHSQ/, result[:urls].first
  end
end