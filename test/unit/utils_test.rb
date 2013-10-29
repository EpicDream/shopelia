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
    assert_equal "effiliation.com", domain
  end
  
  test "it should extract domain from zanox url" do
    domain = Utils.extract_domain "http://ad.zanox.com/ppc/?19054231C2048768278&ULP=[[jeux-jouets.fnac.com/a5782285/DOUETCIE-FND-LAPIN-BONBON-PM-TAUPE]]"
    assert_equal "zanox.com", domain
  end

  test "it should extract domain from tradedoubler url" do
    domain = Utils.extract_domain "http://pdt.tradedoubler.com/click?a(2238732)p(72222)prod(908694445)ttid(5)url(http%3A%2F%2Fwww.cdiscount.com%2Fdp.asp%3Fsku%3DSONYMDRZX100W%26refer%3D*)"
    assert_equal "tradedoubler.com", domain
  end

  test "it should extract domain if url has invalid parameters" do
    domain = Utils.extract_domain "http://www.bienmanger.com?ope=netaff"
    assert_equal "bienmanger.com", domain
  end 

  test "it should safely parse url" do
    assert_not_nil Utils.parse_uri_safely "http://action.metaffiliation.com/trk.php?mclic=P43EF9544D2D15S4519345193C111117180315TRENCH LUNGO"
    assert_not_nil Utils.parse_uri_safely "http://tracking.publicidees.com/clic.php?partid=32430&progid=2013&adfactory_type=12&idfluxpi=500&url=http%3A%2F%2Ftracking.lengow.com%2FshortUrl%2F2082-37081-0421841%2F"
    assert_not_nil Utils.parse_uri_safely "http://www.amazon.fr/Eafit-Protisoya-100%-Proteine-Vegetale/dp/B0036BGQ6W?SubscriptionId=AKIAJMEFP2BFMHZ6VEUA&tag=prixing-web-21&linkCode=xm2&camp=2025&creative=165953&creativeASIN=B0036BGQ6W"
    assert_not_nil Utils.parse_uri_safely "http://www.clarins.fr/pi?url=http://www.clarins.fr/Instant-Definition-Mascara/0421841,fr_FR,pd.html?cm_mmc=Affiliate-_-Nextidea2012-_-Maquillage+>+Yeux+>+Mascaras-_-0421841"
    assert_not_nil Utils.parse_uri_safely "http://www.amazon.fr/SEN-120-Spot-d\\\\exterieur-enterre-12x1W/dp/B003X8O92G?SubscriptionId=AKIAJMEFP2BFMHZ6VEUA&tag=prixing-web-21&linkCode=xm2&camp=2025&creative=165953&creativeASIN=B003X8O92G"
    assert_not_nil Utils.parse_uri_safely "https://www.thinkgeek.com/product/eea5/"
  end

  test "it should strip tracking params" do
    assert_equal "http://www.site.com/product?id=1234", Utils.strip_tracking_params("http://www.site.com/product?id=1234&utm_track=456&cm_mmc=457")
  end
end
