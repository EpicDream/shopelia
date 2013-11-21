# -*- encoding : utf-8 -*-
require 'test_helper'

class Search::AlgoliaApiTest < ActiveSupport::TestCase
 
  test "it should request product by ean" do
    result = Search::AlgoliaApi.ean("5051889226314")
    assert_match /thrones/, result[:name].downcase
    assert_match /http/, result[:image_url]
    assert_match /http/, result[:urls].first
  end

  test "it should set brand" do
    result = Search::AlgoliaApi.ean("5051889363910")
    assert_match /warner/, result[:brand].downcase
  end
end