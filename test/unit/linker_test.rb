# -*- encoding : utf-8 -*-
require 'test_helper'

class LinkerTest < ActiveSupport::TestCase
  fixtures :merchants
 
  test "it should clean url" do
    array = [
      { :in  => "http://track.effiliation.com/servlet/effi.redir?id_compteur=11283848&url=http://www.priceminister.com/offer/buy/103220572/hub-4-ports-usb-avec-rechauffeur-de-tasse-spyker-accessoire.html",
        :out => "http://www.priceminister.com/offer/buy/103220572/hub-4-ports-usb-avec-rechauffeur-de-tasse-spyker-accessoire.html" },
      { :in  => "http://www.priceminister.com/offer/buy/103220572/hub-4-ports-usb-avec-rechauffeur-de-tasse-spyker-accessoire.html",
        :out => "http://www.priceminister.com/offer/buy/103220572/hub-4-ports-usb-avec-rechauffeur-de-tasse-spyker-accessoire.html" },
      { :in  => "http://www.amazon.fr/Port-designs-Detroit-tablettes-pouces/dp/B00BIXXTCY?SubscriptionId=AKIAJMEFP2BFMHZ6VEUA&tag=prixing-web-21&linkCode=xm2&camp=2025&creative=165953&creativeASIN=B00BIXXTCY",
        :out => "http://www.amazon.fr/Port-designs-Detroit-tablettes-pouces/dp/B00BIXXTCY" },
      { :in  => "http://tracking.lengow.com/shortUrl/53-1110-2759446/",
        :out => "http://www.fnac.com/Logitech-Performance-Mouse-MX-Souris-Optique-Laser-Sans-fil/a2759446/w-4" },
      { :in  => "http://ad.zanox.com/ppc/?25134383C1552684717T&ULP=[[www.fnac.com%2FTous-les-Enregistreurs%2FEnregistreur-DVD-Enregistreur-Blu-ray%2Fnsh180760%2Fw-4%23bl%3DMMtvh]]",
        :out => "http://www.fnac.com/Tous-les-Enregistreurs/Enregistreur-DVD-Enregistreur-Blu-ray/nsh180760/w-4" },
      { :in  => "http://ad.zanox.com/ppc/?19436175C242487251&ULP=%5B%5Bm/ps/mpid:MP-0006DM7671064%2523xtor%253dAL-67-75%255blien_catalogue%255d-120001%255bzanox%255d-%255bZXADSPACEID%255d%5D%5D#rueducommerce.fr",
        :out => "http://www.rueducommerce.fr/m/ps/mpid:MP-0006DM7671064" },
      { :in  => "http://pdt.tradedoubler.com/click?a(2238732)p(72222)prod(717215663)ttid(5)url(http%3A%2F%2Fwww.cdiscount.com%2Fdp.asp%3Fsku%3DROSITRIPLE10M%26refer%3D*)",
        :out => "http://www.cdiscount.com/electromenager/lave-vaisselle/rosieres-triple-10m/f-11025-rositriple10m.html" },
      { :in  => "http://ad.zanox.com/ppc/?18920697C1372641144&ULP=%5B%5Bhttp://www.toysrus.fr/redirect_znx.jsp?url=http%3A%2F%2Fwww.toysrus.fr%2Fproduct%2Findex.jsp%3FproductId%3D10863181%5D%5D#toysrus.fr",
        :out => "http://www.toysrus.fr/product/index.jsp?productId=10863181" }
    ]
    array.each do |h|
      assert_equal h[:out], Linker.clean(h[:in])
    end
  end
  
  test "it should use url matcher" do
    assert_difference("UrlMatcher.count", 1) do
      assert_equal "http://www.fnac.com/Logitech-Performance-Mouse-MX-Souris-Optique-Laser-Sans-fil/a2759446/w-4", Linker.clean("http://tracking.lengow.com/shortUrl/53-1110-2759446/")
    end
    assert_equal "http://www.fnac.com/Logitech-Performance-Mouse-MX-Souris-Optique-Laser-Sans-fil/a2759446/w-4", UrlMatcher.first.canonical
    
    assert_difference("UrlMatcher.count", 0) do
      Linker.clean("http://tracking.lengow.com/shortUrl/53-1110-2759446/")
    end   

    assert_difference("UrlMatcher.count", 0) do
      assert_equal "http://www.fnac.com/Logitech-Performance-Mouse-MX-Souris-Optique-Laser-Sans-fil/a2759446/w-4", Linker.clean("http://www.fnac.com/Logitech-Performance-Mouse-MX-Souris-Optique-Laser-Sans-fil/a2759446/w-4")
    end
  end
 
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
  
  test "it should monetize rueducommerce link" do
    url = Linker.monetize "http://www.rueducommerce.fr/m/ps/mpid:MP-0006DM7671064"
    assert_equal "http://ad.zanox.com/ppc/?25390102C2134048814&ulp=[[www.rueducommerce.fr%2Fm%2Fps%2Fmpid%3AMP-0006DM7671064]]", url
  end

end
