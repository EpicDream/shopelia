# -*- encoding : utf-8 -*-
require 'test_helper'

class UtilsTest < ActiveSupport::TestCase
 
  test "it should extract domain from http://www.priceminister.com" do
    domain = Utils.extract_domain "http://www.priceminister.com/offer/buy/103220572/hub-4-ports-usb-avec-rechauffeur-de-tasse-spyker-accessoire.html#sort=0&filter=10&s2m_exaffid=977275"
    assert_equal "priceminister.com", domain
  end

  test "it should extract domain from http://blog.priceminister.com" do
    domain = Utils.extract_domain "http://blog.priceminister.com/offer"
    assert_equal "priceminister.com", domain
  end

  test "it should extract domain from http://priceminister.com" do
    domain = Utils.extract_domain "http://priceminister.com/offer"
    assert_equal "priceminister.com", domain
  end

  test "it should extract domain from http://a.b.c.priceminister.com" do
    domain = Utils.extract_domain "http://a.b.c.priceminister.com/offer"
    assert_equal "priceminister.com", domain
  end

  test "it should extract domain from url with accents" do
    domain = Utils.extract_domain "http://www.priceminister.com/offer/éà"
    assert_equal "priceminister.com", domain
  end

  test "it should extract domain from http://www.shop.co.uk/product" do
    domain = Utils.extract_domain "http://www.shop.co.uk/product"
    assert_equal "shop.co.uk", domain
  end

  test "it should extract domain from effiliation urls" do
    domain = Utils.extract_domain "http://track.effiliation.com/servlet/effi.redir?id_compteur=12345&url=http://www.priceminister.com/offer/buy/103220572/hub-4-ports-usb-avec-rechauffeur-de-tasse-spyker-accessoire.html"
    assert_equal "priceminister.com", domain
  end
  
  test "it should extract domain from zanox url" do
    domain = Utils.extract_domain "http://ad.zanox.com/ppc/?19054231C2048768278&ULP=[[jeux-jouets.fnac.com/a5782285/DOUETCIE-FND-LAPIN-BONBON-PM-TAUPE]]"
    assert_equal "fnac.com", domain
  end

  test "it should extract domain from tradedoubler url" do
    domain = Utils.extract_domain "http://pdt.tradedoubler.com/click?a(2238732)p(72222)prod(908694445)ttid(5)url(http%3A%2F%2Fwww.cdiscount.com%2Fdp.asp%3Fsku%3DSONYMDRZX100W%26refer%3D*)"
    assert_equal "cdiscount.com", domain
  end

  test "it should extract domain if url has invalid parameters" do
    domain = Utils.extract_domain "http://www.bienmanger.com?ope=netaff"
    assert_equal "bienmanger.com", domain
  end  
end