# -*- encoding : utf-8 -*-
require 'test_helper'

class AmazonFrTest < ActiveSupport::TestCase

  setup do
    @helper = AmazonFr.new("http://www.amazon.fr/Port-designs-Detroit-tablettes-pouces/dp/B00BIXXTCY")
    @helper2 = AmazonFr.new("http://www.amazon.fr/Port-designs-Detroit-tablettes-pouces/dp/B00BIXXTCY?SubscriptionId=AKIAJMEFP2BFMHZ6VEUA&linkCode=xm2&camp=2025&creative=165953&creativeASIN=B00BIXXTCY")
  end
  
  test "it should monetize" do
    assert_equal "http://www.amazon.fr/Port-designs-Detroit-tablettes-pouces/dp/B00BIXXTCY?tag=shopelia-21", @helper.monetize
    assert_equal "http://www.amazon.fr/Port-designs-Detroit-tablettes-pouces/dp/B00BIXXTCY?SubscriptionId=AKIAJMEFP2BFMHZ6VEUA&linkCode=xm2&camp=2025&creative=165953&creativeASIN=B00BIXXTCY&tag=shopelia-21", @helper2.monetize
  end

  test "it should canonize" do
    assert_equal "http://www.amazon.fr/dp/B00BIXXTCY", @helper.canonize
  end
end