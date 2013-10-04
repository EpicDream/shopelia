# -*- encoding : utf-8 -*-
require 'test_helper'

class SuperInsoliteComTest < ActiveSupport::TestCase

  setup do
    @version = {}
    @url = "http://www.super-insolite.com/minuteur-zoom-appareil-photo.html?a_aid=4f45473184a6b"
    @helper = SuperInsoliteCom.new(@url)
  end

  test "it should find class from url" do
    assert MerchantHelper.send(:from_url, @url).kind_of?(SuperInsoliteCom)
  end

  test "it should process availability (1)" do
    @version[:availability_text] = "En stock, en stock"
    @version = @helper.process_availability(@version)
    assert_equal "En stock, en stock", @version[:availability_text]
  end

  test "it should process availability (2)" do
    @version[:availability_text] = "Stock,"
    @version = @helper.process_availability(@version)
    assert_equal "Non disponible", @version[:availability_text]
  end

  test "it should process availability (3)" do
    @version[:availability_text] = ""
    @version = @helper.process_availability(@version)
    assert_equal "En stock", @version[:availability_text]
  end

  test "it should process name" do
    @version[:name] = "Coussin Donut Simpsons 22,90 €"
    @version = @helper.process_name(@version)
    assert_equal "Coussin Donut Simpsons", @version[:name]
  end
end