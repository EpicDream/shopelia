# -*- encoding : utf-8 -*-
require 'test_helper'

class ThebodyshopFrTest < ActiveSupport::TestCase

  setup do
    @version = {}
    @helper = ThebodyshopFr.new("http://www.amazon.fr/Port-designs-Detroit-tablettes-pouces/dp/B00BIXXTCY")
    @helper2 = ThebodyshopFr.new("http://www.amazon.fr/Port-designs-Detroit-tablettes-pouces/dp/B00BIXXTCY?SubscriptionId=AKIAJMEFP2BFMHZ6VEUA&linkCode=xm2&camp=2025&creative=165953&creativeASIN=B00BIXXTCY")
  end
  
  test "it should process_price_shipping (1)" do
    @version[:price_text] = "8.95 €"
    @version = @helper.process_shipping_price(@version)
    assert_equal ThebodyshopFr::DEFAULT_PRICE_SHIPPING, @version[:price_shipping_text]
  end

  test "it should process_price_shipping (2)" do
    @version[:price_text] = "40,90 €"
    @version = @helper.process_shipping_price(@version)
    assert_equal "0.00", @version[:price_shipping_text]
  end

  test "it should process availability" do
    @version[:availability_text] = ""
    @version = @helper.process_availability(@version)
    assert_equal MerchantHelper::AVAILABLE, @version[:availability_text]

    str = "Il ne reste plus que 6 exemplaire(s) en stock."
    @version[:availability_text] = str
    @version = @helper.process_availability(@version)
    assert_equal str, @version[:availability_text]
  end
end
