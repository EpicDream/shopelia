# -*- encoding : utf-8 -*-
require 'test_helper'

class RueducommerceFrTest < ActiveSupport::TestCase

  setup do
    @helper = RueducommerceFr.new("http://www.rueducommerce.fr/m/ps/mpid:MP-0006DM7671064")
  end

  test "it should monetize" do
    assert_equal "http://ad.zanox.com/ppc/?25390102C2134048814&ulp=[[www.rueducommerce.fr%2Fm%2Fps%2Fmpid%3AMP-0006DM7671064]]", @helper.monetize
  end
end