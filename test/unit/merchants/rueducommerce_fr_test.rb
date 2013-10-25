# -*- encoding : utf-8 -*-
require 'test_helper'

class RueducommerceFrTest < ActiveSupport::TestCase

  setup do
    @version = {}
    @url = "http://www.rueducommerce.fr/m/ps/mpid:MP-0006DM7671064"
    @helper = RueducommerceFr.new(@url)
  end

  test "it should monetize" do
    assert_equal "http://ad.zanox.com/ppc/?25390102C2134048814&ulp=[[www.rueducommerce.fr%2Fm%2Fps%2Fmpid%3AMP-0006DM7671064]]", @helper.monetize
  end

  test "it should process availability" do
    @version[:availability_text] = ""
    @version[:price_text] = ""
    @version = @helper.process_availability(@version)
    assert_equal "", @version[:availability_text]

    @version[:availability_text] = "N'importe quoi"
    @version[:price_text] = ""
    @version = @helper.process_availability(@version)
    assert_equal "N'importe quoi", @version[:availability_text]

    @version[:availability_text] = "N'importe quoi"
    @version[:price_text] = "3,50 €"
    @version = @helper.process_availability(@version)
    assert_equal "N'importe quoi", @version[:availability_text]

    @version[:availability_text] = ""
    @version[:price_text] = "3,50 €"
    @version = @helper.process_availability(@version)
    assert_equal "En stock", @version[:availability_text]
  end

  test "it should process shipping_info" do
    @version[:shipping_info] = "Dans un certain temps"
    @version = @helper.process_shipping_info(@version)
    assert_equal "Dans un certain temps", @version[:shipping_info]

    @version[:shipping_info] = ""
    @version = @helper.process_shipping_info(@version)
    assert_equal RueducommerceFr::DEFAULT_SHIPPING_INFO, @version[:shipping_info]
  end

  test "it should process price_shipping (1)" do
    @version[:price_shipping_text] = "3,50 €"
    @version = @helper.process_shipping_price(@version)
    assert_equal "3,50 €", @version[:price_shipping_text]

    @version[:price_shipping_text] = ""
    @version = @helper.process_shipping_price(@version)
    assert_equal RueducommerceFr::DEFAULT_SHIPPING_PRICE, @version[:price_shipping_text]
  end

  test "it should process price_shipping (2)" do
    @version[:price_shipping_text] = "3,50 €"
    @version = @helper.process_shipping_price(@version)
    assert_nil @version[:price_shipping]

    @version[:price_shipping_text] = sprintf("%.2f €", RueducommerceFr::FREE_SHIPPING_LIMIT)
    @version = @helper.process_shipping_price(@version)
    assert_equal 0.0, @version[:price_shipping]
  end
end