# -*- encoding : utf-8 -*-
require 'test_helper'

class LinkerTest < ActiveSupport::TestCase
 
  test "it should monetize priceminister" do
    url = Linker.monetize "http://www.priceminister.com/offer/buy/103220572/hub-4-ports-usb-avec-rechauffeur-de-tasse-spyker-accessoire.html#sort=0&filter=10&s2m_exaffid=977275"
    assert_equal "http://track.effiliation.com/servlet/effi.redir?id_compteur=11283848&url=http://www.priceminister.com/offer/buy/103220572/hub-4-ports-usb-avec-rechauffeur-de-tasse-spyker-accessoire.html", url
  end

  test "it should replace priceminister tag" do
    url = Linker.monetize "http://track.effiliation.com/servlet/effi.redir?id_compteur=12345&url=http://www.priceminister.com/offer/buy/103220572/hub-4-ports-usb-avec-rechauffeur-de-tasse-spyker-accessoire.html"
    assert_equal "http://track.effiliation.com/servlet/effi.redir?id_compteur=11283848&url=http://www.priceminister.com/offer/buy/103220572/hub-4-ports-usb-avec-rechauffeur-de-tasse-spyker-accessoire.html", url
  end
  
  test "it shouldn't remonetize already tracked priceminister" do
    url = "http://track.effiliation.com/servlet/effi.redir?id_compteur=11283848&url=http://www.priceminister.com/offer/buy/103220572/hub-4-ports-usb-avec-rechauffeur-de-tasse-spyker-accessoire.html"
    assert_equal url, Linker.monetize(url)
  end
 
  test "it should replace tag in amazon link" do
    url = Linker.monetize "http://www.amazon.fr/Port-designs-Detroit-tablettes-pouces/dp/B00BIXXTCY?SubscriptionId=AKIAJMEFP2BFMHZ6VEUA&tag=prixing-web-21&linkCode=xm2&camp=2025&creative=165953&creativeASIN=B00BIXXTCY"
    assert_equal "http://www.amazon.fr/Port-designs-Detroit-tablettes-pouces/dp/B00BIXXTCY?SubscriptionId=AKIAJMEFP2BFMHZ6VEUA&tag=shopelia-21&linkCode=xm2&camp=2025&creative=165953&creativeASIN=B00BIXXTCY", url
  end 
  
  test "it should add tag in amazon link" do
    url = Linker.monetize "http://www.amazon.fr/Port-designs-Detroit-tablettes-pouces/dp/B00BIXXTCY"
    assert_equal "http://www.amazon.fr/Port-designs-Detroit-tablettes-pouces/dp/B00BIXXTCY?tag=shopelia-21", url  
    url = Linker.monetize "http://www.amazon.fr/Port-designs-Detroit-tablettes-pouces/dp/B00BIXXTCY?SubscriptionId=AKIAJMEFP2BFMHZ6VEUA&linkCode=xm2&camp=2025&creative=165953&creativeASIN=B00BIXXTCY"
    assert_equal "http://www.amazon.fr/Port-designs-Detroit-tablettes-pouces/dp/B00BIXXTCY?SubscriptionId=AKIAJMEFP2BFMHZ6VEUA&linkCode=xm2&camp=2025&creative=165953&creativeASIN=B00BIXXTCY&tag=shopelia-21", url
  end 

  test "it shouldn't change already monetized amazon url" do
    url = "http://www.amazon.fr/Port-designs-Detroit-tablettes-pouces/dp/B00BIXXTCY?SubscriptionId=AKIAJMEFP2BFMHZ6VEUA&tag=shopelia-21&linkCode=xm2&camp=2025&creative=165953&creativeASIN=B00BIXXTCY"
    assert_equal url, Linker.monetize(url)
  end

  test "it should not change non monetizable link" do
    url = "http://www.prixing.fr"
    assert_equal url, Linker.monetize(url)
  end  

  test "it should unaccent link" do
    url = Linker.monetize "http://www.prixing.fr/éà"
    assert_equal "http://www.prixing.fr/ea", url
  end  

  test "it should ignore blank url" do
    url = Linker.monetize ""
    assert url.nil?
    url = Linker.monetize nil
    assert url.nil?
  end  
  
  test "it should monetize fnac url" do
    url = Linker.monetize "http://www.fnac.com/Tous-les-Enregistreurs/Enregistreur-DVD-Enregistreur-Blu-ray/nsh180760/w-4#bl=MMtvh"
    assert_equal "http://ad.zanox.com/ppc/?25134383C1552684717T&ULP=[[www.fnac.com%2FTous-les-Enregistreurs%2FEnregistreur-DVD-Enregistreur-Blu-ray%2Fnsh180760%2Fw-4%23bl%3DMMtvh]]", url
  end
  
  test "it should monetize zanox fnac url" do
    url = Linker.monetize "http://ad.zanox.com/ppc/?19054231C2048768278&ULP=[[jeux-jouets.fnac.com/a5782285/DOUETCIE-FND-LAPIN-BONBON-PM-TAUPE]]#fnac"
    assert_match /^http\:\/\/ad.zanox.com\/ppc\/\?25134383C1552684717T&ULP=\[\[www4.fnac.com%2FDoudou\-et\-Compagnie\-Lapin\-Bonbon\-Petit\-Modele\-Taupe/, url
    url = Linker.monetize "http://ad.zanox.com/ppc/?19054231C2048768278&ULP=%5B%5Bjeux-jouets.fnac.com/a5073437/Lego-Duplo-Ville-10503-Le-numero-des-otaries%5D%5D#fnac.com"
    assert_match /^http\:\/\/ad.zanox.com\/ppc\/\?25134383C1552684717T&ULP=\[\[www4.fnac.com%2FLego\-Duplo\-Ville\-10503\-Le\-numero\-des\-otaries%2Fa5073437%2Fw-4/, url
  end
  
  test "it shouldn't change already monetized fnac url" do
    url = "http://ad.zanox.com/ppc/?25134383C1552684717T&ULP=[[www4.fnac.com%2FLego-Duplo-Ville-10503-Le-numero-des-otaries%2Fa5073437%2Fw-4%3FSID%3D25b9c27e-f46e-d24b-08e6-06c45cf2faad%26UID%3D0F7E11BF8-2B20-3497-C86D-CA150AD123FD%26Origin%3Dzanox1464273%26OrderInSession%3D1%26TTL%3D161220131934%26ectrans%3D1]]"
    assert_equal url, Linker.monetize(url)
  end
  
end
