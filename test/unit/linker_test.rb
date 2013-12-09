# -*- encoding : utf-8 -*-
require 'test_helper'

class LinkerTest < ActiveSupport::TestCase

  setup do
    Redis.new.del "url_canonizer_cache"
  end
  test "it should clean url" do
    array = [
      { :in  => 'http://tracking.publicidees.com/clic.php?partid=37027&progid=737&adfactory_type=12&idfluxpi=191&url=http://tracker.marinsm.com/rd?cid=1535bsz11407&mkwid=s9eoQ2T70&kword=Redirect+Flux&lp=http://www.rugbycenter.fr/fr/rugby/f-ligue-nationale-de-rugby-mug-collector-top-14-2012-2013-851550.html',
        :out => 'http://www.rugbycenter.fr/fr/rugby/f-ligue-nationale-de-rugby-mug-collector-top-14-2012-2013-851550.html' },
      { :in  => 'http://ad.zanox.com/ppc/?25341675C892987421&ulp=[[http://fr.topshop.com/fr/tsfr/produit/v%25C3%25AAtements-415222/jeans-415241/jeans-mom-1758875/jean-mom-ultra-doux-d%25C3%25A9lav%25C3%25A9-%25C3%25A0-taille-haute-exclusivit%25C3%25A9-internet-2281379?refinements=category~[1070115|345719]&bi=1&ps=20]]',
        :out => 'http://fr.topshop.com/fr/tsfr/produit/jean-mom-ultra-doux-délavé-à-taille-haute-exclusivité-internet-2281379'},
      { :in  => "http://ad.zanox.com/ppc/?16606400C728069979&ulp=[[http://www.asos.fr/referrer/pgereferrer.aspx?path=www.asos.fr/House-Of-Holland-Nails-By-Elegant-Touch-Polka-Dot-It-Faux-ongles-%C3%A0-pois/11uh2e/?iid=3623437&SearchQuery=polka%20dots&sh=0&pge=0&pgesize=36&sort=-1&clr=Polkadot&mporgp=L0V5bHVyZS9Ib3VzZS1PZi1Ib2xsYW5kLU5haWxzLUJ5LUVsZWdhbnQtVG91Y2gtLS1Qb2xrYS1Eb3QtSXQvUHJvZC8.]]",
        :out => "http://www.asos.fr/11uh2e/?iid=3623437" },
      { :in  => "http://api.shopstyle.com/action/apiVisitRetailer?pid=puid14728235&url=http://www.barneys.com/on/demandware.store/Sites-BNY-Site/default/Product-Show?pid=502921664",
        :out => "http://www.barneys.com/on/demandware.store/Sites-BNY-Site/default/Product-Show?pid=502921664" },
      { :in  => "http://rstyle.me/n/c92f6m4xn",
        :out => "http://www.alexandermcqueen.com/fr/mcq/veste_cod49134687.html" },
      { :in  => 'http://track.webgains.com/click.html?wgcampaignid=145659&amp;wgprogramid=3900&amp;product=1&amp;wglinkid=120411&amp;productname=MEDION%C2%AE+LIFE%C2%AE+P89626+Serveur+NAS+1%2C5+To+%28MD+86407%29&amp;wgtarget=http://a.nonstoppartner.net/a/?i=click&amp;client=medion&amp;l=fr&amp;camp=deep&amp;nw=wga1&amp;msn=50043049&amp;deepid=MEDION%25C2%25AE%2BLIFE%25C2%25AE%2BP89626%2BServeur%2BNAS%2B1%252C5%2BTo%2B%2528MD%2B86407%2529%2F50043049A1%3Fcategory%3Dnetwork_devices',
        :out => 'http://www.medion.com/fr/prod/MEDION+LIFE+P89626+Serveur+NAS+1,5+To+(MD+86407)/50043049A1?category=network_devices&pAction=8797534929027&wt_cc1=deep&wt_cc2=50043049&wt_cc3=&wt_mc=fr.extern.affiliate.webgains.nonstop' },
      { :in  => "http://track.effiliation.com/servlet/effi.redir?id_compteur=11283848&url=http://www.priceminister.com/offer/buy/103220572/hub-4-ports-usb-avec-rechauffeur-de-tasse-spyker-accessoire.html",
        :out => "http://www.priceminister.com/offer/buy/103220572" },
      { :in  => "http://www.priceminister.com/offer/buy/103220572/hub-4-ports-usb-avec-rechauffeur-de-tasse-spyker-accessoire.html",
        :out => "http://www.priceminister.com/offer/buy/103220572" },
      { :in  => "http://www.amazon.fr/Port-designs-Detroit-tablettes-pouces/dp/B00BIXXTCY?SubscriptionId=AKIAJMEFP2BFMHZ6VEUA&tag=prixing-web-21&linkCode=xm2&camp=2025&creative=165953&creativeASIN=B00BIXXTCY",
        :out => "http://www.amazon.fr/dp/B00BIXXTCY" },
      { :in  => "http://tracking.lengow.com/shortUrl/53-1110-2759446/",
        :out => "http://www.fnac.com/Logitech-Performance-Mouse-MX-Souris-Optique-Laser-Sans-fil/a2759446/w-4" },
      { :in  => "http://ad.zanox.com/ppc/?25134383C1552684717T&ULP=[[www.fnac.com%2FTous-les-Enregistreurs%2FEnregistreur-DVD-Enregistreur-Blu-ray%2Fnsh180760%2Fw-4%23bl%3DMMtvh]]",
        :out => "http://www.fnac.com/Tous-les-Enregistreurs/Enregistreur-DVD-Enregistreur-Blu-ray/nsh180760/w-4" },
      { :in  => "http://pdt.tradedoubler.com/click?a(2238732)p(72222)prod(717215663)ttid(5)url(http%3A%2F%2Fwww.cdiscount.com%2Fdp.asp%3Fsku%3DROSITRIPLE10M%26refer%3D*)",
        :out => "http://www.cdiscount.com/dp.asp?sku=ROSITRIPLE10M" },
      { :in  => "http://ad.zanox.com/ppc/?19024603C1357169475&ULP=%5B%5Bhttp://logc57.xiti.com/gopc.url?xts=425426&xtor=AL-146-%5Btypologie%5D-%5BREMPLACE%5D-%5Bflux%5D&xtloc=http://www.eveiletjeux.com/mallette-tag-junior/produit/145303&url=http://www.eveiletjeux.com/Commun/Xiti_Redirect.htm%5D%5D#eveiletjeux.com",
        :out => "http://www.eveiletjeux.com/mallette-tag-junior/produit/145303" },
      { :in  => "http://www.amazon.fr/Eafit-Protisoya-100%-Proteine-Vegetale/dp/B0036BGQ6W?SubscriptionId=AKIAJMEFP2BFMHZ6VEUA&tag=prixing-web-21&linkCode=xm2&camp=2025&creative=165953&creativeASIN=B0036BGQ6W",
        :out => "http://www.amazon.fr/dp/B0036BGQ6W" },
      { :in  => "http://action.metaffiliation.com/trk.php?mclic=P43EF9544D2D15S4519345193C111117180315TRENCH LUNGO",
        :out => "http://www.zinefashionstore.com/produit-homme-Trench_de_la_marque_Memento-4030.html" },
      { :in  => "http%3A%2F%2Fwww.amazon.fr%2FConverse-Chuck-Taylor-Baskets-adulte%2Fdp%2FB000EDMSTY%2Fref%3Dsr_1_1%3Fs%3Dshoes%26ie%3DUTF8%26qid%3D1380531062%26sr%3D1-1",
        :out => "http://www.amazon.fr/dp/B000EDMSTY" },
      { :in  => "http://ad.zanox.com/ppc/?19089773C1754659089&ULP=%5B%5Bhttp://www.imenager.com/aspirateur-main/fp-843138-black-et-decker?site=zanox&utm_source=Zanox&utm_medium=Affiliation&utm_campaign=ZanoxIM%5D%5D#imenager.com",
        :out => "http://www.imenager.com/aspirateur-main/fp-843138-black-et-decker" },
      { :in  => "http://stat.dealtime.com/DealFrame/DealFrame.cmp?bm=121&BEFID=63715&acode=95&code=95&aon=&crawler_id=1910893&dealId=KbSndLHBDQcax43wwQi7dQ%3D%3D&searchID=&url=http%3A%2F%2Fwww.amazon.fr%2Fdp%2F2253022632%2Fref%3Dasc_df_225302263215505771%3Fsmid%3DA1X6FK5RDHNB96%26tag%3Dshoppingcom_books_param_rt-21%26linkCode%3Dasn%26creative%3D22782%26creativeASIN%3D2253022632&DealName=Blaze&MerchantID=400092&HasLink=yes&category=0&AR=-1&NG=1&GR=1&ND=1&PN=1&RR=-1&ST=&MN=msnFeed&FPT=SDCF&NDS=1&NMS=1&NDP=1&MRS=&PD=0&brnId=3682&lnkId=8079593&Issdt=131023223159&IsFtr=0&IsSmart=0&dlprc=6.75&SKU=2253022632",
        :out => "http://www.amazon.fr/dp/2253022632" }
    ]
    array.each do |h|
      assert_equal h[:out], Linker.clean(h[:in])
    end

    assert_match(%r!\Ahttp://.+?\.topshop.com/fr/tsfr/produit/bonnet-en-grosse-maille-tricoté-à-la-main-2192228\Z!, Linker.clean('http://bit.ly/1aChLeB'))

  end
 
  test "it shouldn't generate incident if link is not monetizable" do
    UrlMonetizer.new.del("http://www.newshop.com/productA")
    assert_difference "Incident.count", 0 do
      Linker.monetize "http://www.newshop.com/productA"
    end
    assert_difference "Incident.count", 0 do
      Linker.monetize "http://www.newshop.com/productB"
    end
    #Incident.last.update_attribute :processed, true
    #assert_difference "Incident.count", 0 do
    #  Linker.monetize "http://www.newshop.com/productC"
    #end
  end

  test "it shouldn't generate incident if url monetizer has a value" do
    UrlMonetizer.new.set("http://www.newshop.com/productA", "http://www.newshop.com/productA/aff")
    assert_difference "Incident.count", 0 do
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

  test "it should monetize url using merchant helper" do
    url = Linker.monetize "http://www.amazon.fr/Port-designs-Detroit-tablettes-pouces/dp/B00BIXXTCY"
    assert_equal "http://www.amazon.fr/Port-designs-Detroit-tablettes-pouces/dp/B00BIXXTCY?tag=shopelia-21", url  

    url = Linker.monetize "http://www.priceminister.com/offer/buy/103220572/hub-4-ports-usb-avec-rechauffeur-de-tasse-spyker-accessoire.html#sort=0&filter=10&s2m_exaffid=977275"
    assert_equal "http://track.effiliation.com/servlet/effi.redir?id_compteur=12712494&url=http%3A%2F%2Fwww.priceminister.com%2Foffer%2Fbuy%2F103220572%2Fhub-4-ports-usb-avec-rechauffeur-de-tasse-spyker-accessoire.html", url
  end
end
