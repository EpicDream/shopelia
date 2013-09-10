# -*- encoding : utf-8 -*-
require 'test_helper'

class ProductVersionTest < ActiveSupport::TestCase
  
  setup do
    @product = products(:usbkey)
    @version = ProductVersion.new(product_id:@product.id)
  end  

  test "it should create version" do
    assert @version.save, @version.errors.full_messages.join(",")
  end
  
  test "it shouldn't allow duplication for sizes and colors" do
    v = ProductVersion.new(
      product_id:@product.id,
      color:"blue",
      size:"32")
    assert v.save
    v = ProductVersion.new(
      product_id:@product.id,
      color:"red",
      size:"32")
    assert v.save
    v = ProductVersion.new(
      product_id:@product.id,
      color:"red",
      size:"30")    
    assert v.save
    v = ProductVersion.new(
      product_id:@product.id,
      color:"blue",
      size:"32")    
    assert !v.save
    v = ProductVersion.new(
      product_id:products(:headphones).id,
      color:"blue",
      size:"32")    
    assert v.save
  end

  test "it should create version with data" do
    version = ProductVersion.new(
       product_id:@product.id,
       price:"10€",
       reference:"reference")
    assert version.save, version.errors.full_messages.join(",")
    assert_equal 10, version.price
    assert_equal "reference", version.reference
  end

  test "it should truncate name to 250 chars" do
    version = ProductVersion.new(
      product_id:@product.id,
      name: "0" * 500
    )
    assert version.save
    
    assert_equal 250, version.name.length
  end

  test "it should parse float" do
    str = [ "2.79€", "2,79 EUR", "bla bla 2.79", "2€79", 
            "2��79", "2,79 €7,30 €", "2€79 6€30", "2,79 ��7,30 ��", 
            "2��79 6��30" ]
    str.each { |s| check_price s, 2.79 }

    str = [ "2", "2€", "Bla bla 2 €" ]
    str.each { |s| check_price s, 2 }

    str = [ "1 739,95 €", "1739€95", "1 739 € 95", "1 739€95", "1 739€ 95", "1739 €95", "1739.95", "bla 1 739.95 EUR" ]
    str.each { |s| check_price s, 1739.95 }

    str = [ "1 739€", "1739€", "bla bla 1739 E bla" ]
    str.each { |s| check_price s, 1739 }

    str = [ "12 739€", "12 739€", "bla 12739" ]
    str.each { |s| check_price s, 12739 }
  end

  test "it should parse free shipping" do
    str = [ "LIVRAISON GRATUITE", "free shipping", "Livraison offerte" ]
    str.each do |s|
      @version.price_shipping_text = s
      @version.save
      assert_equal 0, @version.price_shipping, s
    end
  end

  test "it should fail bad prices" do
    str = [ ".", "invalid" ]
    str.each do |s|
      @version.price_text = s
      @version.save
      assert_equal nil, @version.price, s
    end
  end
  
  test "it should generate incident if shipping is not correctly parsed" do
    assert_difference "Incident.count", 1 do
      @version.price_shipping_text = "Invalid string"
      @version.save
    end
  end

  test "it should generate incident if shipping price is too high" do
    assert_difference "Incident.count", 0, "price=1000 and shipping_price=151 should pass" do
      @version.price_text = "1000"
      @version.price_shipping_text = "151"
      @version.save
    end
    assert_difference "Incident.count", 0, "price=15 and shipping_price=9 should pass" do
      @version.price_text = "15"
      @version.price_shipping_text = "9"
      @version.save
    end
    assert_difference "Incident.count", 0, "price=15 and shipping_price=149 should pass" do
      @version.price_text = "15"
      @version.price_shipping_text = "149"
      @version.save
    end
    assert_difference "Incident.count", 0, "price=300 and shipping_price=149 should pass" do
      @version.price_text = "300"
      @version.price_shipping_text = "149"
      @version.save
    end
    assert_difference "Incident.count", 1, "price=15 and shipping_price=151 should not pass" do
      @version.price_text = "15"
      @version.price_shipping_text = "151"
      @version.save
    end
    assert_difference "Incident.count", 1, "price=300 and shipping_price=151 should not pass" do
      @version.price_text = "300"
      @version.price_shipping_text = "151"
      @version.save
    end
  end
  
  test "it should create version with prices" do
    version = ProductVersion.new(
      product_id:@product.id,
      price:"2.79",
      price_shipping:"1",
      price_strikeout:"10.0")
    assert version.save, version.errors.full_messages.join(",")
    assert_equal 2.79, version.price
    assert_equal 1.0, version.price_shipping
    assert_equal 10.0, version.price_strikeout
  end
  
  test "it should set available info" do
    array = [ "Aucun vendeur ne propose ce produit", "out of stock", "en rupture de stock", 
              "temporairement en rupture de stock.", "sur commande", "article indisponible",
              "ce produit est epuise", "sans stock pour vos criteres", "bientot disponible",
              "produit epuise", "inscrivez-vous pour etre prevenu lorsque cet article sera disponible",
              "retrait gratuit en magasin", "dans plus de 50 magasins", "dans 48 magasins" ]
    array.each do |str|
      version = ProductVersion.create(
        product_id:@product.id,
        availability_text:str)
      assert !version.available, "#{str.inspect} failed !"
      assert_equal str, version.availability_info
    end
    
    array = [ "en stock", "8 offres", "en vente sur", "Précommandez maintenant pour réserver votre Kindle Paperwhite.",
              "Expédié habituellement sous 2 à 3 semaines", "Peu de stock", "Stock modéré" ]
    array.each do |str|
      version = ProductVersion.create(
        product_id:@product.id,
        availability_text:str)
      assert version.available, "#{str.inspect} failed !"
      assert_equal str, version.availability_info
    end
  end
  
  test "it should generate incident if unknown availability (and set as available by default)" do
    assert_difference "Incident.count", 1 do
      version = ProductVersion.create(
        product_id:@product.id,
        availability_text:"bla")
      assert version.available
    end
  end

  test "it shouldnt generate incident if availability is known and mapped to true" do
    assert_difference "Incident.count", 0 do
      version = ProductVersion.create(
        product_id:@product.id,
        availability_text:"en precommande")
      assert version.available
    end
  end
  
  test "it shouldn't be destroyed if related to an order" do
    assert @version.destroy
    assert !product_versions(:usbkey).destroy
  end

  test "it should send 0 for cashfront value if no rule" do
    version = ProductVersion.create!(
      product_id:@product.id,
      price:"100",
      price_shipping:"10")

    assert_equal 0, version.cashfront_value(developer:developers(:prixing))
  end
  
  test "it should compute cashfront value" do
    version = ProductVersion.create!(
      product_id:products(:dvd).id,
      price:"100",
      price_shipping:"10")

    assert_equal 3, version.cashfront_value(100, developer:developers(:prixing))
  end

  test "it should sanitize description (1)" do
    @version.description = <<__END

<h3 class="productDescriptionSource"></h3> <div class="productDescriptionWrapper"> <p>filtre à eau.</p><p>compatible avec tous les modèles de frigo lg</p> <div class="emptyClear"> </div> </div>

__END
    @version.save
    
    assert_equal "<h3></h3> <p>filtre à eau.</p> <p>compatible avec tous les modèles de frigo lg</p>", @version.description
  end

  test "it should sanitize description (2)" do
    @version.description = <<__END
<div id="ccs-inline-content"></div><link href="http://www.cdiscount.com/include/CSS/tdv.css" rel="stylesheet" type="text/css"> 
<style> 
.lien_offre { 
FONT-FAMILY: Arial; COLOR: #848077; FONT-SIZE: 10pt; FONT-WEIGHT: bold; TEXT-DECORATION: none 
} 
.titre_bloc_0 { 
FONT-FAMILY: Arial; COLOR: #000000; FONT-SIZE: 10pt 
} 

.preload { 
BACKGROUND-IMAGE: url(../images/zoomloader.gif); Z-INDEX: 10; BORDER-BOTTOM: #ccc 1px solid; POSITION: absolute; TEXT-ALIGN: center; FILTER: alpha(opacity = 80); BORDER-LEFT: #ccc 1px solid; PADDING-BOTTOM: 8px; BACKGROUND-COLOR: white; PADDING-LEFT: 8px; WIDTH: 100px; PADDING-RIGHT: 8px; BACKGROUND-REPEAT: no-repeat; FONT-FAMILY: Tahoma; BACKGROUND-POSITION: 43px 30px; HEIGHT: 55px; COLOR: #333; FONT-SIZE: 12px; BORDER-TOP: #ccc 1px solid; TOP: 3px; BORDER-RIGHT: #ccc 1px solid; TEXT-DECORATION: none; PADDING-TOP: 8px; LEFT: 3px; -moz-opacity: 0.8; opacity: 0.8 
} 
.jqZoomWindow { 
BORDER-BOTTOM: #999 1px solid; BORDER-LEFT: #999 1px solid; BACKGROUND-COLOR: #fff; BORDER-TOP: #999 1px solid; BORDER-RIGHT: #999 1px solid 
} 
</style> 
<!-- tableau global --> 
<table width="100%" style="background-color: white;" cellspacing="0" cellpadding="0"> 
<tbody> 
<tr> 
<td valign="top"><!-- tableau layout --> 
<table width="587" align="center" style="width: 587px; height: 977px;" cellspacing="0" cellpadding="0"> 
<script language="javascript" src="http://www.cdiscount.com/include/js/integrationFlashNew.js"></script> 
<tbody> 
<tr> 
<td> 
<table style="filter: none; margin-bottom: 5px;" border="0" cellspacing="0" cellpadding="0"> 
<!-- ligne du template --> 
<tbody> 
<tr> 
<td align="center"> 
<table width="100%" style="padding-left: 4px; padding-right: 4px;" border="0" cellspacing="0" cellpadding="0"> 
<tbody> 
<tr> 
<td align="center" valign="top" style="height: 100%;"> 
<table height="100%" align="center" border="0" cellspacing="0" cellpadding="0"> 
<tbody> 
<tr> 
<td><img alt="" id="img_20612" style="width: 392px; height: 109px;" data-src="http://i5.cdscdn.com/other/20612.jpg" src="http://i3.cdscdn.com/imagesok/rien.gif"></td> 
</tr> 
</tbody> 
</table> 
</td> 
</tr> 
</tbody> 
</table> 
</td> 
</tr> 
</tbody> 
</table> 
</td> 
</tr> 
<tr> 
<td> 
<table style="filter: none; margin-bottom: 5px;" border="0" cellspacing="0" cellpadding="0"> 
<!-- ligne du template --> 
<tbody> 
<tr> 
<td align="center"> 
<table width="100%" style="padding-left: 4px; padding-right: 4px;" border="0" cellspacing="0" cellpadding="0"> 
<tbody> 
<tr> 
<td align="center" valign="top" style="height: 100%;"> 
<table width="100%" height="100%" border="0" cellspacing="0" cellpadding="0"> 
<tbody> 
<tr> 
<td><span style="font-size: 8px;"></span></td> 
</tr> 
<tr> 
<td> 
<table width="100%" style="font-weight: bold;" cellspacing="0" cellpadding="0"> 
<tbody> 
<tr> 
<td align="center" class="titre_bloc_28" style="white-space: nowrap;">Matelas 140x190 DORSOLATEX </td> 
</tr> 
</tbody> 
</table> 
</td> 
</tr> 
<tr> 
<td> 
<table width="566" height="328" align="center" style="width: 566px; font-family: arial; height: 328px; color: #3c505b; font-size: 12px;" border="0" cellspacing="0" cellpadding="0"> 
<tbody> 
<tr> 
<td><span style="color: #ff0000; font-size: small;"><strong> 
<p style="text-align: center;"> 
</p><table border="0" cellpadding="0"> 
<tbody> 
<tr> 
<td style="padding-bottom: 0.75pt; background-color: transparent; padding-left: 0.75pt; padding-right: 0.75pt; padding-top: 0.75pt;border: #ece9d8;"> 
<p style="text-align: center;"><span style="font-family: arial; font-size: 14px;">Passez de belles nuits avec le&nbsp;<strong>matelas</strong><span style="color: #000000; font-size: small;"><strong> 140x190 DORSOLATEX <br> 
100% latex de 23 cm</strong> </span>et ses <strong>5 zones de confort.<br> 
<br> 
<br> 
&nbsp;Un confort ergonomique !</strong></span></p> 
</td> 
</tr> 
<tr> 
<td style="padding-bottom: 0.75pt; background-color: transparent; padding-left: 0.75pt; padding-right: 0.75pt; padding-top: 0.75pt;border: #ece9d8;"> 
<p style="text-align: center;"><span style="font-family: arial; color: #000000; font-size: 10pt;">&nbsp;&nbsp;&nbsp;&nbsp;La plupart des maux de dos sont dus à un matelas trop dur ou trop mou qui génère des points de pression induisant des douleurs lombaires ou articulaires. Le matelas dorsolatex est composé d’un noyau 100% latex âme de 16 cm avec 5 zones de confort. Ce latex de qualité offre une résilience qui permet de répartir la pression sur l'ensemble du corps et détend ainsi les muscles pour un sommeil récupérateur.&nbsp;<br> 
<br> 
<strong><span style="font-size: 14px;">Le Latex<br> 
<br> 
</span></strong><img alt="" id="img_30382" data-src="http://i5.cdscdn.com/other/30382.jpg" src="http://i3.cdscdn.com/imagesok/rien.gif"></span></p> 
</td> 
</tr> 
</tbody> 
</table> 
<p></p> 
</strong></span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <img alt="" id="img_30557" data-src="http://i5.cdscdn.com/other/30557.jpg" src="http://i3.cdscdn.com/imagesok/rien.gif"><img style="border: 0px solid;" alt="Matelas Dorsolatex" data-src="http://i3.cdiscount.com/imagesok/medias/10/149523.jpg" src="http://i3.cdscdn.com/imagesok/rien.gif"></td> 
</tr> 
</tbody> 
</table> 
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <img style="border: 0px solid;" alt="Matelas Dorsolatex" data-src="http://i3.cdiscount.com/imagesok/medias/10/149537.jpg" src="http://i3.cdscdn.com/imagesok/rien.gif"></td> 
</tr> 
</tbody> 
</table> 
</td> 
</tr> 
</tbody> 
</table> 
<p style="text-align: right;"><span style="font-size: 10px; text-decoration: underline;">Matelas fabriqué en Belgique<br> 
</span></p> 
</td> 
</tr> 
</tbody> 
</table> 
</td> 
</tr> 
<tr> 
<td></td> 
</tr> 
</tbody> 
</table> 
</td> 
</tr> 
</tbody> 
</table>
__END

    @version.save 
    assert_equal "<table><tbody><tr> <td> <table><tbody> <tr> <td> <table><tbody><tr> <td> <table><tbody><tr> <td> <table><tbody><tr> <td></td> </tr></tbody></table> </td> </tr></tbody></table> </td> </tr></tbody></table> </td> </tr> <tr> <td> <table><tbody><tr> <td> <table><tbody><tr> <td> <table><tbody> <tr> <td></td> </tr> <tr> <td> <table><tbody><tr> <td>Matelas 140x190 DORSOLATEX </td> </tr></tbody></table> </td> </tr> <tr> <td> <table><tbody><tr> <td> <strong> <p> </p> <table><tbody> <tr> <td> <p>Passez de belles nuits avec le <strong>matelas</strong><strong> 140x190 DORSOLATEX <br> 100% latex de 23 cm</strong> et ses <strong>5 zones de confort.<br><br><br>  Un confort ergonomique !</strong></p> </td> </tr> <tr> <td> <p>    La plupart des maux de dos sont dus à un matelas trop dur ou trop mou qui génère des points de pression induisant des douleurs lombaires ou articulaires. Le matelas dorsolatex est composé d’un noyau 100% latex âme de 16 cm avec 5 zones de confort. Ce latex de qualité offre une résilience qui permet de répartir la pression sur l'ensemble du corps et détend ainsi les muscles pour un sommeil récupérateur. <br><br><strong>Le Latex<br><br></strong></p> </td> </tr> </tbody></table> <p></p> </strong>            </td> </tr></tbody></table>                  </td> </tr> </tbody></table> </td> </tr></tbody></table> <p>Matelas fabriqué en Belgique<br></p> </td> </tr></tbody></table> </td> </tr> <tr> <td></td> </tr> </tbody></table> </td> </tr></tbody></table>", @version.description
  end
  
  test "it should sanitize description (3)" do
    @version.description =<<__END
<ul class="contributors"><li class="sub"><span class="label">Fabricant&nbsp;: </span><em class="value"><a href="javascript:void PM.BT.ubs(47,'s',47,'olympus')" class="pmbt pmbtjs ft_link">Olympus</a></em></li> <li class="sub"><span class="label">Référence fabricant&nbsp;: </span><em class="value">V104080UE000 - TG320BLEU</em></li></ul> 
<p class="edito"></p><div>Achetez un appareil photo, c'est comme s'offrir une paire de lunettes de soleil; on a toujours peur de les casser la première fois qu'on les sort de leur étui! C'est pour éviter toutes ces craintes qu'Olympus a développé sa série de compacts, tout-terrain: résistants aux chocs, étanches, et au froid extrême. Une gamme quasi indestructible!<br>Le TG-320 dispose de nombreuses fonctionnalités automatiques qui permettent de photographier sans complexe toutes les situations, même les plus compliquées. Et afin de garantir la meilleure qualité des photos de groupe ou d'un sujet éloigné, celui-ci est équipé d'un zoom optique grand angle. Le TG-320 est le compagnon idéal des aventuriers. Avec cet appareil, pas besoin de prendre des précautions il suffit juste de s'amuser et de saisir l'instant!<br>Pour s'approcher au plus près de la réalité le TG-320 est doté de la fonction 3D utilisable même sous l'eau. Il est également équipé de filtres artistiques pour donner une touche de créativité à vos photos. Et pour revivre et partager les moments forts rien de plus simple via la carte Eye-Fi. Avec toutes ses fonctionnalités, ses performances technologiques et sa robustesse, le TG-320 est exceptionnel sans oublier son rapport qualité/prix.<br></div><br><p></p> 
<p class="edito"></p><div><ul><li>Zoom optique 3.6x grand angle</li><li>14 méga pixels</li><li>Ecran LCD 6.9cm/ 2.7"</li><li>Double stabilisation d'image</li><li>Filtres artistiques pour les vidéos et photos</li><li>Détection de visage et SAT</li><li>Mode photo 3D</li><li>Mode beauté</li><li>Mode détection animaux</li><li>Compatible carte Eye-Fi</li><li>Chargeur de batterie via USB</li></ul></div><br><p></p> 
<div class="specs_ctn"> 
<div class="spec_table"> 
<p class="table_caption">Général</p> 
<table class="spec_table_ctn"> 
<tbody> 
<tr class="odd first_child"> 
<th class="label first_child"><span>Type de Produit</span></th> 
<td class="value last_child"><span>Appareil photo numérique - compact</span></td> 
</tr> 
<tr class="even"> 
<th class="label first_child"><span>Couleur du boîtier</span></th> 
<td class="value last_child"><span>Bleu</span></td> 
</tr> 
<tr class="odd"> 
<th class="label first_child"><span>Résolution du Capteur</span></th> 
<td class="value last_child"><span>14.0 mégapixel</span></td> 
</tr> 
<tr class="odd last_child"> 
<th class="label first_child"><span>Interfaces AV</span></th> 
<td class="value last_child"><span>Audio/vidéo composite, HDMI</span></td> 
</tr> 
</tbody> 
</table> 
</div> 
</div> 
__END
    @version.save
    assert_equal "<ul> <li> Fabricant : <em>Olympus</em> </li> <li> Référence fabricant : <em>V104080UE000 - TG320BLEU</em> </li> </ul><p></p> Achetez un appareil photo, c'est comme s'offrir une paire de lunettes de soleil; on a toujours peur de les casser la première fois qu'on les sort de leur étui! C'est pour éviter toutes ces craintes qu'Olympus a développé sa série de compacts, tout-terrain: résistants aux chocs, étanches, et au froid extrême. Une gamme quasi indestructible!<br>Le TG-320 dispose de nombreuses fonctionnalités automatiques qui permettent de photographier sans complexe toutes les situations, même les plus compliquées. Et afin de garantir la meilleure qualité des photos de groupe ou d'un sujet éloigné, celui-ci est équipé d'un zoom optique grand angle. Le TG-320 est le compagnon idéal des aventuriers. Avec cet appareil, pas besoin de prendre des précautions il suffit juste de s'amuser et de saisir l'instant!<br>Pour s'approcher au plus près de la réalité le TG-320 est doté de la fonction 3D utilisable même sous l'eau. Il est également équipé de filtres artistiques pour donner une touche de créativité à vos photos. Et pour revivre et partager les moments forts rien de plus simple via la carte Eye-Fi. Avec toutes ses fonctionnalités, ses performances technologiques et sa robustesse, le TG-320 est exceptionnel sans oublier son rapport qualité/prix.<br> <br><p></p> <p></p> <ul> <li>Zoom optique 3.6x grand angle</li> <li>14 méga pixels</li> <li>Ecran LCD 6.9cm/ 2.7\"</li> <li>Double stabilisation d'image</li> <li>Filtres artistiques pour les vidéos et photos</li> <li>Détection de visage et SAT</li> <li>Mode photo 3D</li> <li>Mode beauté</li> <li>Mode détection animaux</li> <li>Compatible carte Eye-Fi</li> <li>Chargeur de batterie via USB</li> </ul> <br><p></p> <p>Général</p> <table><tbody> <tr> <th>Type de Produit</th> <td>Appareil photo numérique - compact</td> </tr> <tr> <th>Couleur du boîtier</th> <td>Bleu</td> </tr> <tr> <th>Résolution du Capteur</th> <td>14.0 mégapixel</td> </tr> <tr> <th>Interfaces AV</th> <td>Audio/vidéo composite, HDMI</td> </tr> </tbody></table>", @version.description
  end

test "it should sanitize description (4)" do
    @version.description =<<__END   
<div class="content">
  <div id="outer_postBodyPS" style="overflow: hidden; z-index: 1; height: auto;">
    <div id="postBodyPS" style="overflow: hidden;">
      <div><b>Découvrez la suite du phénomène international : Eva et Gideon doivent faire face aux démons de leurs passés respectifs et accepter les conséquences de leurs désirs obsessionnels...</b></div>
    </div>
  </div>
  <div id="psGradient" class="psGradient" style="display:none;"></div>
  <div id="psPlaceHolder" style="display:none; height: 20px;">
    <div id="expandPS" style="display:none; z-index: 3;">
      <span class="swSprite s_expandChevron"></span>
      <a class="showMore" onclick="amz_expandPostBodyDescription('PS', ['psGradient', 'psPlaceHolder']); return false;" href="#">Afficher plus</a>
    </div>
  </div>
  <div id="collapsePS" style="display:none; padding-top: 3px;">
    <span class="swSprite s_collapseChevron"></span>
    <a class="showLess" onclick="amz_collapsePostBodyDescription('PS', ['psGradient', 'psPlaceHolder']); return false;" href="#">Réduire</a>
  </div>
  <noscript>
    &lt;style type='text/css'&gt;
    #outer_postBodyPS {
    display: none;
    }
    #psGradient {
    display: none;
    }
    #psPlaceHolder {
    display: none;
    }
    #psExpand {
    display: none;
    }
    &lt;/style&gt;
    &lt;div id="postBodyPS"&gt;&lt;b&gt;D&amp;#xE9;couvrez la suite du ph&amp;#xE9;nom&amp;#xE8;ne international : Eva et Gideon doivent faire face aux d&amp;#xE9;mons de leurs pass&amp;#xE9;s respectifs et accepter les cons&amp;#xE9;quences de leurs d&amp;#xE9;sirs obsessionnels...&lt;/b&gt;&lt;/div&gt;
  </noscript>
</div>
__END
    @version.save
    assert_equal "<b>Découvrez la suite du phénomène international : Eva et Gideon doivent faire face aux démons de leurs passés respectifs et accepter les conséquences de leurs désirs obsessionnels...</b>", @version.description
end

  private
  
  def check_price s, p
    @version.price_text = s
    @version.price_strikeout_text = s
    @version.price_shipping_text = s
    @version.save
    assert_equal p, @version.price, s
    assert_equal p, @version.price_strikeout, s
    assert_equal p, @version.price_shipping, s
  end  
    
end
