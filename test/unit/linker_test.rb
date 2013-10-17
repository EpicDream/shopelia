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
        :out => "http://www.amazon.fr/dp/B00BIXXTCY" },
      { :in  => "http://tracking.lengow.com/shortUrl/53-1110-2759446/",
        :out => "http://www.fnac.com/Logitech-Performance-Mouse-MX-Souris-Optique-Laser-Sans-fil/a2759446/w-4" },
      { :in  => "http://ad.zanox.com/ppc/?25134383C1552684717T&ULP=[[www.fnac.com%2FTous-les-Enregistreurs%2FEnregistreur-DVD-Enregistreur-Blu-ray%2Fnsh180760%2Fw-4%23bl%3DMMtvh]]",
        :out => "http://www.fnac.com/Tous-les-Enregistreurs/Enregistreur-DVD-Enregistreur-Blu-ray/nsh180760/w-4" },
      { :in  => "http://ad.zanox.com/ppc/?19436175C242487251&ULP=%5B%5Bm/ps/mpid:MP-0006DM7671064%2523xtor%253dAL-67-75%255blien_catalogue%255d-120001%255bzanox%255d-%255bZXADSPACEID%255d%5D%5D#rueducommerce.fr",
        :out => "http://www.rueducommerce.fr/m/ps/mpid:MP-0006DM7671064" },
      { :in  => "http://pdt.tradedoubler.com/click?a(2238732)p(72222)prod(717215663)ttid(5)url(http%3A%2F%2Fwww.cdiscount.com%2Fdp.asp%3Fsku%3DROSITRIPLE10M%26refer%3D*)",
        :out => "http://www.cdiscount.com/electromenager/four-cuisson/rosieres-triple-10m/f-11023020709-rositriple10m.html" },
      { :in  => "http://www.eveiletjeux.com/Commun/Xiti_Redirect.htm?xts=425426&xtor=AL-146-[typologie]-[1532882]-[flux]&xtloc=http://www.eveiletjeux.com/ordinateur-genius-malice-orange/produit/300068&xtdt=22932563",
        :out => "http://www.eveiletjeux.com/ordinateur-genius-malice-orange/produit/300068" },
      { :in  => "http://ad.zanox.com/ppc/?19024603C1357169475&ULP=%5B%5Bhttp://logc57.xiti.com/gopc.url?xts=425426&xtor=AL-146-%5Btypologie%5D-%5BREMPLACE%5D-%5Bflux%5D&xtloc=http://www.eveiletjeux.com/mallette-tag-junior/produit/145303&url=http://www.eveiletjeux.com/Commun/Xiti_Redirect.htm%5D%5D#eveiletjeux.com",
        :out => "http://www.eveiletjeux.com/mallette-tag-junior/produit/145303" },
      { :in  => "http://action.metaffiliation.com/trk.php?mclic=P3138544D2D222S1UC431296294177V3",
        :out => "http://www.avenuedesjeux.com/playmobil-playmobil-5302-maison-de-ville.36324.html" },
      { :in  => "http://ad.zanox.com/ppc/?19436175C242487251&ULP=%5B%5BAccessoires-Consommables/showdetl.cfm?product_id=4855986%2523xtor%253dAL-67-75%255blien_catalogue%255d-120001%255bzanox%255d-%255bZXADSPACEID%255d%5D%5D#rueducommerce.fr",
        :out => "http://www.rueducommerce.fr/Accessoires-Consommables/showdetl.cfm?product_id=4855986" },
      { :in  => "http://clic.reussissonsensemble.fr/click.asp?ref=593625&site=10393&type=text&tnb=2&diurl=http://tracking.lengow.com/shortUrl/2857-45667-C389183/",
        :out => "http://www.auchan.fr/achat4/CA17234/color_47063/size_10055" },
      { :in  => "http://www.amazon.fr/Eafit-Protisoya-100%-Proteine-Vegetale/dp/B0036BGQ6W?SubscriptionId=AKIAJMEFP2BFMHZ6VEUA&tag=prixing-web-21&linkCode=xm2&camp=2025&creative=165953&creativeASIN=B0036BGQ6W",
        :out => "http://www.amazon.fr/dp/B0036BGQ6W" },
      { :in  => "http://action.metaffiliation.com/trk.php?mclic=P43EF9544D2D15S4519345193C111117180315TRENCH LUNGO",
        :out => "http://www.zinefashionstore.com/produit-homme-Trench_de_la_marque_Memento-4030.html" },
      { :in  => "http://tracking.publicidees.com/clic.php?partid=32430&progid=2013&adfactory_type=12&idfluxpi=500&url=http%3A%2F%2Ftracking.lengow.com%2FshortUrl%2F2082-37081-0421841%2F",
        :out => "http://www.clarins.fr/Instant-Definition-Mascara/0421841,fr_FR,pd.html" },
      { :in  => "http://www.koordinal.com/74-bac-%C3%A0-gla%C3%A7on-igloo.html",
        :out => "http://www.koordinal.com/74-bac-a-glacons-igloo.html" },
      { :in  => "http%3A%2F%2Fwww.amazon.fr%2FConverse-Chuck-Taylor-Baskets-adulte%2Fdp%2FB000EDMSTY%2Fref%3Dsr_1_1%3Fs%3Dshoes%26ie%3DUTF8%26qid%3D1380531062%26sr%3D1-1",
        :out => "http://www.amazon.fr/dp/B000EDMSTY" }
    ]
    array.each do |h|
      assert_equal h[:out], Linker.clean(h[:in])
    end
  end
  
  test "it should use url matcher" do
    assert_difference("UrlMatcher.count", 2) do
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
    assert_difference "Incident.count", 0 do
      Linker.monetize "http://www.newshop.com/productB"
    end
    Incident.last.update_attribute :processed, true
    assert_difference "Incident.count", 1 do
      Linker.monetize "http://www.newshop.com/productC"
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

  test "it should monetize url using merchant helper" do
    url = Linker.monetize "http://www.amazon.fr/Port-designs-Detroit-tablettes-pouces/dp/B00BIXXTCY"
    assert_equal "http://www.amazon.fr/Port-designs-Detroit-tablettes-pouces/dp/B00BIXXTCY?tag=shopelia-21", url  

    url = Linker.monetize "http://www.priceminister.com/offer/buy/103220572/hub-4-ports-usb-avec-rechauffeur-de-tasse-spyker-accessoire.html#sort=0&filter=10&s2m_exaffid=977275"
    assert_equal "http://track.effiliation.com/servlet/effi.redir?id_compteur=12712494&url=http://www.priceminister.com/offer/buy/103220572/hub-4-ports-usb-avec-rechauffeur-de-tasse-spyker-accessoire.html", url
  end
end
