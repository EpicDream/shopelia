# -*- encoding : utf-8 -*-
require 'test_helper'

class ImenagerComTest < ActiveSupport::TestCase

  setup do
    @version = {}
    @url = "http://www.imenager.com/accessoire-cuisson/fp-336342-seb?site=zanox&amp;utm_source=Zanox&amp;utm_medium=Affiliation&amp;utm_campaign=ZanoxIM"
    @helper = ImenagerCom.new(@url)
  end

  test "it should find class from url" do
    assert MerchantHelper.send(:from_url, @url).kind_of?(ImenagerCom)
  end

  test "it should canonize" do
    assert_equal "http://www.imenager.com/accessoire-cuisson/fp-336342-seb", @helper.canonize
  end
end