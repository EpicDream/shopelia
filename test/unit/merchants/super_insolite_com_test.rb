# -*- encoding : utf-8 -*-
require 'test_helper'

class SuperInsoliteComTest < ActiveSupport::TestCase

  setup do
    @version = {}
    @helper = SuperInsoliteCom.new("http://www.super-insolite.com/minuteur-zoom-appareil-photo.html?a_aid=4f45473184a6b")
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
end