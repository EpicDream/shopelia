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

end