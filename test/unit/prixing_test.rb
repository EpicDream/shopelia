# -*- encoding : utf-8 -*-
require 'test_helper'

class PrixingTest < ActiveSupport::TestCase
 
  test "it should request product by ean" do
    result = Prixing::Product.get("9782749910116")
    assert result.first['product'].present?
  end
end
