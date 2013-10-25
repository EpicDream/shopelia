# -*- encoding : utf-8 -*-
require 'test_helper'

class ImenagerComTest < ActiveSupport::TestCase

  setup do
    @helper = FnacCom.new("http://www.imenager.com/accessoire-cuisson/fp-336342-seb?site=zanox&amp;utm_source=Zanox&amp;utm_medium=Affiliation&amp;utm_campaign=ZanoxIM")
  end

  test "it should canonize" do
    assert_equal "http://www.imenager.com/accessoire-cuisson/fp-336342-seb", @helper.canonize
  end
end