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
    url = Linker.monetize "http://ad.zanox.com/ppc/?19054231C2048768278&ULP=[[jeux-jouets.fnac.com/a5782285/DOUETCIE-FND-LAPIN-BONBON-PM-TAUPE]]"
    assert_equal "http://ad.zanox.com/ppc/?25134383C1552684717T&ULP=[[jeux-jouets.fnac.com/a5782285/DOUETCIE-FND-LAPIN-BONBON-PM-TAUPE]]", url
  end
  
  test "it shouldn't change already correctly monetized fnac url" do
    url = "http://ad.zanox.com/ppc/?25134383C1552684717T&ULP=%5B%5Blivre.fnac.com/a1000650/H-Kohler-Les-enfants-agites-anxieux-tristes%5D%5D"
    assert_equal url, Linker.monetize(url)
  end

#    http://ad.zanox.com/ppc/?19054231C2048768278&ULP=%5B%5Blivre.fnac.com/a1000048/Omraam-Mikhael-Aivanhov-L-homme-dans-l-organisme-cosmique%5D%5D#fnac.com
  
end
