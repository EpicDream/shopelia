# -*- encoding : utf-8 -*-
require 'test_helper'

class AmazonFrTest < ActiveSupport::TestCase

  setup do
    @version = {}
    @helper = AmazonFr.new("http://www.amazon.fr/Port-designs-Detroit-tablettes-pouces/dp/B00BIXXTCY")
    @helper2 = AmazonFr.new("http://www.amazon.fr/Port-designs-Detroit-tablettes-pouces/dp/B00BIXXTCY?SubscriptionId=AKIAJMEFP2BFMHZ6VEUA&linkCode=xm2&camp=2025&creative=165953&creativeASIN=B00BIXXTCY")
    @version = {}
  end
  
  test "it should monetize" do
    assert_equal "http://www.amazon.fr/Port-designs-Detroit-tablettes-pouces/dp/B00BIXXTCY?tag=shopelia-21", @helper.monetize
    assert_equal "http://www.amazon.fr/Port-designs-Detroit-tablettes-pouces/dp/B00BIXXTCY?SubscriptionId=AKIAJMEFP2BFMHZ6VEUA&linkCode=xm2&camp=2025&creative=165953&creativeASIN=B00BIXXTCY&tag=shopelia-21", @helper2.monetize
  end

  test "it should canonize" do
    assert_equal "http://www.amazon.fr/dp/B00BIXXTCY", @helper.canonize
    assert_equal "http://www.amazon.fr/gp/product/B00E7OA2EE", AmazonFr.new("http://www.amazon.fr/gp/product/B00E7OA2EE/ref=s9_al_bw_g23_ir04?pf_rd_m=A1X6FK5RDHNB96&pf_rd_s=center-2&pf_rd_r=0ENBSWCDW130V5QJKZEV&pf_rd_t=101&pf_rd_p=431613487&pf_rd_i=13910691").canonize
  end

  test "it should process_price_shipping (1)" do
    @version[:price_shipping_text] = "livraison gratuite"
    @version = @helper.process_shipping_price(@version)
    assert_nil @version[:price_shipping]
  end

  test "it should process_price_shipping (2)" do
    @version[:price_shipping_text] = "Livraison gratuite dès 15 euros d'achats."
    @version[:price_text] = "EUR 5,90"
    @version = @helper.process_shipping_price(@version)
    assert_equal 2.79, @version[:price_shipping]
  end

  test "it should process_price_shipping (3)" do
    @version[:price_shipping_text] = "Livraison gratuite dès 15 euros d'achats."
    @version[:price_text] = "EUR 15,90"
    @version = @helper.process_shipping_price(@version)
    assert_equal 0.0, @version[:price_shipping]
  end

  test "it should process availability" do
    @version[:availability_text] = "Voir les offres de ces vendeurs"
    @version = @helper.process_availability(@version)
    assert_equal "En stock", @version[:availability_text]

    @version[:availability_text] = "Il ne reste plus que 6 exemplaire(s) en stock."
    @version = @helper.process_availability(@version)
    assert_equal "En stock", @version[:availability_text]
  end  
end
