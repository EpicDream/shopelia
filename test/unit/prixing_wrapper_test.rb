# -*- encoding : utf-8 -*-
require 'test_helper'

class PrixingWrapperTest < ActiveSupport::TestCase
 
  setup do
    prixing_result = Prixing::Product.get("9782749910116")
    @result = PrixingWrapper.convert(prixing_result)
  end

  test "it should set name" do
    assert_match /Métronome/, @result[:name]
  end

  test "it should set image url" do
    assert_equal "http://www.prixing.fr/images/product_images/b6a/b6aacf56d04df065e64aa3f6c4eb2faf.jpg", @result[:image_url]
  end

  test "it should set prices" do
    assert @result[:urls].count > 0
  end
end
