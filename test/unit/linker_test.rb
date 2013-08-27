# -*- encoding : utf-8 -*-
require 'test_helper'

class LinkerTest < ActiveSupport::TestCase
 
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
        :out => "http://www.toysrus.fr/product/index.jsp?productId=10863181" },
      { :in  => "http://www.eveiletjeux.com/Commun/Xiti_Redirect.htm?xts=425426&xtor=AL-146-[typologie]-[1532882]-[flux]&xtloc=http://www.eveiletjeux.com/ordinateur-genius-malice-orange/produit/300068&xtdt=22932563",
        :out => "http://www.eveiletjeux.com/ordinateur-genius-malice-orange/produit/300068" }
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
 
  test "it should generate incident if link is not monetizable" do
    assert_difference "Incident.count", 1 do
      Linker.monetize "http://www.newshop.com/productA"
    end
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

  test "it should monetize amazon" do
    url = Linker.monetize "http://www.amazon.fr/Port-designs-Detroit-tablettes-pouces/dp/B00BIXXTCY"
    assert_equal "http://www.amazon.fr/Port-designs-Detroit-tablettes-pouces/dp/B00BIXXTCY?tag=shopelia-21", url  
    url = Linker.monetize "http://www.amazon.fr/Port-designs-Detroit-tablettes-pouces/dp/B00BIXXTCY?SubscriptionId=AKIAJMEFP2BFMHZ6VEUA&linkCode=xm2&camp=2025&creative=165953&creativeASIN=B00BIXXTCY"
    assert_equal "http://www.amazon.fr/Port-designs-Detroit-tablettes-pouces/dp/B00BIXXTCY?SubscriptionId=AKIAJMEFP2BFMHZ6VEUA&linkCode=xm2&camp=2025&creative=165953&creativeASIN=B00BIXXTCY&tag=shopelia-21", url
  end 
  
  test "it should monetize priceminister" do
    url = Linker.monetize "http://www.priceminister.com/offer/buy/103220572/hub-4-ports-usb-avec-rechauffeur-de-tasse-spyker-accessoire.html#sort=0&filter=10&s2m_exaffid=977275"
    assert_equal "http://track.effiliation.com/servlet/effi.redir?id_compteur=11283848&url=http://www.priceminister.com/offer/buy/103220572/hub-4-ports-usb-avec-rechauffeur-de-tasse-spyker-accessoire.html", url
  end

  test "it should monetize fnac url" do
    url = Linker.monetize "http://www.fnac.com/Tous-les-Enregistreurs/Enregistreur-DVD-Enregistreur-Blu-ray/nsh180760/w-4#bl=MMtvh"
    assert_equal "http://ad.zanox.com/ppc/?25134383C1552684717T&ULP=[[www.fnac.com%2FTous-les-Enregistreurs%2FEnregistreur-DVD-Enregistreur-Blu-ray%2Fnsh180760%2Fw-4%23bl%3DMMtvh]]", url
  end
  
  test "it should monetize rueducommerce link" do
    url = Linker.monetize "http://www.rueducommerce.fr/m/ps/mpid:MP-0006DM7671064"
    assert_equal "http://ad.zanox.com/ppc/?25390102C2134048814&ulp=[[www.rueducommerce.fr%2Fm%2Fps%2Fmpid%3AMP-0006DM7671064]]", url
  end

  test "it should monetize eveiletjeux link" do
    url = Linker.monetize "http://www.eveiletjeux.com/bac-a-sable-pop-up/produit/306367"
    assert_equal "http://ad.zanox.com/ppc/?25424162C654654636&ulp=[[http://logc57.xiti.com/gopc.url?xts=425426&xtor=AL-146-1%5Btypologie%5D-REMPLACE-%5Bparam%5D&xtloc=http://www.eveiletjeux.com/bac-a-sable-pop-up/produit/306367&url=http://www.eveiletjeux.com/Commun/Xiti_Redirect.htm]]", url
  end

  test "it should monetize toysrus link" do
    url = Linker.monetize "http://www.toysrus.fr/product/index.jsp?productId=11621761"
    assert_equal "http://ad.zanox.com/ppc/?25465502C586468223&ulp=[[http://www.toysrus.fr/redirect_znx.jsp?url=http://www.toysrus.fr/product/index.jsp?productId=11621761&]]", url
  end
  
  test "it should monetize cdiscount link" do
    url = Linker.monetize "http://www.cdiscount.com/electromenager/aspirateur-nettoyeur-vapeur/dirt-devil-m2828-3/f-110140405-dirtm28283.html"
    assert_equal "http://pdt.tradedoubler.com/click?a(2238732)p(72222)prod(765856165)ttid(5)url(http%3A%2F%2Fwww.cdiscount.com%2Felectromenager%2Faspirateur-nettoyeur-vapeur%2Fdirt-devil-m2828-3%2Ff-110140405-dirtm28283.html)", url
  end  

  test "it should monetize darty link" do  
    url = Linker.monetize "http://www.darty.com/nav/achat/gros_electromenager/refrigerateur_congelateur-refrigerateur-cong/refrigerateur_congelateur_bas/samsung_rl56gsbsw.html"
    assert_equal "http://ad.zanox.com/ppc/?25424898C784334680&ulp=[[www.darty.com/nav/achat/gros_electromenager/refrigerateur_congelateur-refrigerateur-cong/refrigerateur_congelateur_bas/samsung_rl56gsbsw.html?dartycid=aff_zxpublisherid_lien-profond-libre_lientexte]]", url
  end

end
