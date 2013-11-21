# -*- encoding : utf-8 -*-
require 'test_helper'

class Search::EanTest < ActiveSupport::TestCase
 
  test "it should request product by ean" do
    result = Search::Ean.get("5051889226314")
    assert_match /thrones/, result[:name].downcase
    assert_match /warner/, result[:brand].downcase
    assert_match /http/, result[:image_url]
    assert_match /http/, result[:urls].first
    assert_equal 1, result[:urls].map{ |e| e if e =~ /amazon/ }.compact.count
  end
end