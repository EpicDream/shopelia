# -*- encoding : utf-8 -*-
require 'test_helper'

class MerchantHelperTest < ActiveSupport::TestCase

  setup do
    @version = {}
  end

  test "it should use url monetizer" do 
    url = "http://www.alinea.fr/product"
    UrlMonetizer.new.set(url, "http://www.alinea.fr/product-m")
    assert_equal "http://www.alinea.fr/product-m", MerchantHelper.monetize(url)
  end

  test "it should use merchant monetize before url monetizer" do
    url = "http://www.priceminister.com/offer/buy/141950480"
    UrlMonetizer.new.set(url, "http://www.priceminister.com/offer/buy/141950480?m")
    assert_equal "http://track.effiliation.com/servlet/effi.redir?id_compteur=12712494&url=http%3A%2F%2Fwww.priceminister.com%2Foffer%2Fbuy%2F141950480", MerchantHelper.monetize(url)
  end

  test "it should process image_url" do 
    @version[:image_url] = "//amazon.fr/image.jpg"
    @version = MerchantHelper.process_version("http://www.amazon.fr", @version)

    assert_equal "http://amazon.fr/image.jpg", @version[:image_url]
  end

  test "it should parse float" do
    str = [ "2.79€", "2,79 EUR", "bla bla 2.79", "2€79", "2€ 79",
            "2��79", "2,79 €7,30 €", "2€79 6€30", "2,79 ��7,30 ��",
            "2��79 6��30", "sur rdv devant chez vous (6 à 10 jours). 2.79 €",
            "livraison à domicile (1 livreur) (le livreur (au pied de l'immeuble si vous êtes en appartement) 2 bla...) 2.79 €",
            "Livraison dans la pièce de votre choix (EUR 2,79)", "Livraison dans la pièce de votre choix (2.79 €)",
            "Livraison 'classique' à domicile (Livraison dans les 4 à 9 jours à bla. En savoir plus 2.79 €",
            "Colissimo - expédié sous 0h - à partir de 2,79 €", "=  2 € 79",
            "Colissimo Suivi - expédié sous 72h - à partir de 2,79 €",
            "Livraison Standard - expédié sous 18 jours - à partir de 2,79 €",
            "Livraison colissimo 48H - expédié sous 48h - à partir de 2,79 €",
            "So Colissimo (2 à 4 jours). - expédié sous 4 jours - à partir de 2,79 €",
            "Livré par Gls sous 48 à 72h contre signature - expédié sous 72h - à partir de 2,79 €" ]
    str.each { |s| assert_equal 2.79, MerchantHelper.parse_float(s) }

    str = [ "2", "2€", "Bla bla 2 €" ]
    str.each { |s| assert_equal 2, MerchantHelper.parse_float(s) }

    str = [ "1 739,95 €", "1739€95", "1 739 € 95", "1 739€95", "1 739€ 95", "1739 €95", "1739.95", "bla 1 739.95 EUR" ]
    str.each { |s| assert_equal 1739.95, MerchantHelper.parse_float(s) }

    str = [ "1 739€", "1739€", "bla bla 1739 E bla" ]
    str.each { |s| assert_equal 1739, MerchantHelper.parse_float(s) }

    str = [ "12 739€", "12 739€", "bla 12739" ]
    str.each { |s| assert_equal 12739, MerchantHelper.parse_float(s) }

    # Special cases
    assert_equal 136.48, MerchantHelper.parse_float("+ Eco Part : 1,50€ soit un total de 136,48€")
    assert_equal 11.99, MerchantHelper.parse_float("so colissimo (2 à 4 jours). 11.99 €")
    assert_equal 159.20, MerchantHelper.parse_float("159,00 € + Éco-part: 0,20 € soit 159,20 € 4 x 39,80 €")
  end

  test "it should parse free shipping" do
    str = [ "LIVRAISON GRATUITE", "free shipping", "Livraison offerte", "Standard - expédié sous 72h - Frais de port offers" ]
    str.each { |s| assert_equal 0.0, MerchantHelper.parse_float(s) }
  end

  test "it should fail bad prices" do
    str = [ ".", "invalid" ]
    str.each { |s| assert_equal nil, MerchantHelper.parse_float(s) }
  end

  test "it should parse_rating" do
    array = [ "4", "4.0", "4/5", "4.0/5", "(4.0/5)",
      "4 / 5", "4.0 / 5", "(4.0 / 5)",
      "4.0 étoiles sur 5", "4.0 out of 5"]
    array.each do |str|
      assert_equal 4.0, MerchantHelper.parse_rating(str)
    end

    array = [ "3.5", "3.5/5", "(3.5/5)",
      "3.5 / 5", "(3.5 / 5)",
      "3.5 étoiles sur 5", "3.5 out of 5"]
    array.each do |str|
      assert_equal 3.5, MerchantHelper.parse_rating(str)
    end
  end

  test "it should parse_availability to true" do
    assert_equal true, MerchantHelper.parse_availability(MerchantHelper::AVAILABLE)[:avail]

    array = [ "en stock", "8 offres", "en vente sur", "Précommandez maintenant pour réserver votre Kindle Paperwhite.",
              "Expédié habituellement sous 2 à 3 semaines", "Peu de stock", "Stock modéré",
              "disponible sous 4 semaines", "Seulement 1 en stock", "in stock but may require an extra 1-2 days to process.",
              "Conditions spéciales :- livraison : 10 semaines", "livraison des fichiers", "attention : dernières pièces disponibles",
              "In stock", "Available for Immediate Shipment.", "Please allow 4-6 weeks for delivery.", "expected ship date",
              "disponible", "Délai 3 à 5 jours", "1 article disponible", "Plus que 7 produits chez notre fournisseur",
              "Plus que 9 produits disponibles", "Dernière paire !", "Plus que 3 paires !", "EN COURS DE RÉAPPRO", "Plus que 2 articles !"
              "More than 10 available", "1 available", "Last one", "Dernier article !", "STOCKS LIMITÉS", "stock limité",
              "4 disponible(s)", "Plus de 10 disponibles", "Il ne reste plus que 1 exemplaire(s) en stock.", "Only 2 left." ]
    array.each do |str|
      assert_equal true, MerchantHelper.parse_availability(str)[:avail], "with #{str}"
    end
  end

  test "it should parse_availability to false" do
    assert_equal false, MerchantHelper.parse_availability(MerchantHelper::UNAVAILABLE)[:avail]

    array = [ "Aucun vendeur ne propose ce produit", "out of stock", "en rupture de stock",
              "temporairement en rupture de stock.", "sur commande", "article indisponible",
              "ce produit est epuise", "sans stock pour vos criteres", "bientot disponible",
              "produit epuise", "inscrivez-vous pour etre prevenu lorsque cet article sera disponible",
              "retrait gratuit en magasin", "dans plus de 50 magasins", "dans 48 magasins",
              "non disponible", "Désolés, cet article a été vendu. Vous aimerez peut-être ceci",
              "Mince alors. Cet article n'est plus disponible.", "Ce magasin est en vacances",
              "ce produit n'est plus en stock", "PAS DE CADEAUX INSOLITES ... CONTINUEZ VOTRE NAVIGATION",
              "For Personalized Service on this item please call 1-800-227-3528 and our Product Specialists will gladly answer all questions and provide additional information. Please note that special conditions and guarantee limitations apply to this product.",
              "404", "Vous recherchez une page ?", "Coming Soon", "Produit en rupture", "Ouille, cette page est introuvable !!!",
              "Epuisé", "pas disponible", "Currently unavailable., Currently unavailable.", "Rupture de stock",
              "Erreur: Désolé, mais le produit que vous avez demandé n'a pas été trouvé !",
              "La page que vous recherchez est introuvable.", "Ce produit n'existe plus ! Mais...",
              "CE PRODUIT N’EST MALHEUREUSEMENT PLUS DISPONIBLE.", "L'article ne peut pas être affiché.",
              "Currently unavailable.", "SOLD OUT", "0 available", "Disponible uniquement en magasin",
              "Ce produit n'est plus commercialisé par Maisons du Monde", "Nous n'avons pas trouvé la page que vous recherchiez.",
              "Item not available. Select a colour and a size and add it to your Wishlist. We will notify you by e-mail if it becomes available again.",
              "Es tut uns leid. Der gesuchte Artikel ist leider nicht mehr verfügbar. Im Folgenden zeigen wir Ihnen Produkte, die Ihrer Suche ähnlich sind: strickmütze",
              "Dieser Artikel ist nicht verfügbar. Wählen Sie eine Farbe und eine Größe aus und setzen Sie ihn auf Ihre Wishlist. Wir benachrichtigen Sie per E-Mail, wenn er wieder verfügbar ist.",
              "Es wurden keine Resultate gefunden für tuch mit fleckenprint Hier finden Sie die Resultate für tuch mit flecken",
              "We're sorry. The page you're looking for cannot be found.", "SORRY, WE COULDN'T FIND A MATCH FOR \"KARENWALKER\".  DID YOU MEAN WALKER?",
              "Nous n'avons pas trouvé de résultat correspondant à votre recherche.", "Agotado",
              "Artículo no disponible. Selecciona un color y una talla y añádelo a tu Wishlist. Te avisaremos por email si vuelve a estar disponible.",
              "An error has occurred." ]
    array.each do |str|
      assert_equal false, MerchantHelper.parse_availability(str)[:avail], "with #{str}"
    end
  end

  test "it should parse_availability to nil" do
    array = [ "35 €", "Vert", "Peut être qu'il est dispo, peut être pas", "Erreur 500" ]
    array.each do |str|
      assert_equal nil, MerchantHelper.parse_availability(str)[:avail]
    end
  end

  test "it should process_availability (1)" do
    helper = MerchantHelper.new
    helper.config[:setAvailableIfEmpty] = false
    helper.config[:setUnavailableIfEmpty] = false

    version = {availability_text: ""}
    helper.process_availability version
    assert_equal "", version[:availability_text]

    text = "Il est reste peut être"
    version = {availability_text: text}
    helper.process_availability version
    assert_equal text, version[:availability_text]
  end

  test "it should process_availability (2)" do
    helper = MerchantHelper.new
    helper.config[:setAvailableIfEmpty] = true
    helper.config[:setUnavailableIfEmpty] = false

    version = {availability_text: ""}
    helper.process_availability version
    assert_equal MerchantHelper::AVAILABLE, version[:availability_text]

    text = "Il est reste peut être"
    version = {availability_text: text}
    helper.process_availability version
    assert_equal text, version[:availability_text]
  end

  test "it should process_availability (3)" do
    helper = MerchantHelper.new
    helper.config[:setAvailableIfEmpty] = false
    helper.config[:setUnavailableIfEmpty] = true

    version = {availability_text: ""}
    helper.process_availability version
    assert_equal MerchantHelper::UNAVAILABLE, version[:availability_text]

    text = "Il est reste peut être"
    version = {availability_text: text}
    helper.process_availability version
    assert_equal text, version[:availability_text]
  end

  test "it should process_availability (4)" do
    helper = MerchantHelper.new
    helper.config[:setAvailableIfEmpty] = true
    helper.config[:setUnavailableIfEmpty] = true

    version = {availability_text: ""}
    helper.process_availability version
    assert_equal MerchantHelper::AVAILABLE, version[:availability_text]

    text = "Il est reste peut être"
    version = {availability_text: text}
    helper.process_availability version
    assert_equal text, version[:availability_text]
  end


  test "it should process_price_shipping without default-free-always-ifempty" do
    helper = MerchantHelper.new
    helper.default_price_shipping = nil
    helper.free_shipping_limit = nil
    helper.config[:setDefaultPriceShippingAlways] = false
    helper.config[:setDefaultPriceShippingIfEmpty] = false

    version = {price_shipping_text: ""}
    helper.process_price_shipping version
    assert_equal "", version[:price_shipping_text]

    text = "3 € 50"
    version = {price_shipping_text: text}
    helper.process_price_shipping version
    assert_equal text, version[:price_shipping_text]
  end

  test "it should process_price_shipping with default-always and without free-ifempty" do
    helper = MerchantHelper.new
    helper.default_price_shipping = "4 € 50"
    helper.free_shipping_limit = nil
    helper.config[:setDefaultPriceShippingAlways] = true
    helper.config[:setDefaultPriceShippingIfEmpty] = false

    version = {price_shipping_text: ""}
    helper.process_price_shipping version
    assert_equal helper.default_price_shipping, version[:price_shipping_text]

    text = "3 € 50"
    version = {price_shipping_text: text}
    helper.process_price_shipping version
    assert_equal helper.default_price_shipping, version[:price_shipping_text]
  end

  test "it should process_price_shipping with default-ifempty and without free-always" do
    helper = MerchantHelper.new
    helper.default_price_shipping = "4 € 50"
    helper.free_shipping_limit = nil
    helper.config[:setDefaultPriceShippingAlways] = false
    helper.config[:setDefaultPriceShippingIfEmpty] = true

    version = {price_shipping_text: ""}
    helper.process_price_shipping version
    assert_equal helper.default_price_shipping, version[:price_shipping_text]

    text = "3 € 50"
    version = {price_shipping_text: text}
    helper.process_price_shipping version
    assert_equal text, version[:price_shipping_text]
  end

  test "it should process_price_shipping with default-ifempty-always and without free" do
    helper = MerchantHelper.new
    helper.default_price_shipping = "4 € 50"
    helper.free_shipping_limit = nil
    helper.config[:setDefaultPriceShippingAlways] = true
    helper.config[:setDefaultPriceShippingIfEmpty] = true

    version = {price_shipping_text: ""}
    helper.process_price_shipping version
    assert_equal helper.default_price_shipping, version[:price_shipping_text]

    text = "3 € 50"
    version = {price_shipping_text: text}
    helper.process_price_shipping version
    assert_equal helper.default_price_shipping, version[:price_shipping_text]
  end

  test "it should process_price_shipping with free and without default-ifempty-always" do
    helper = MerchantHelper.new
    helper.default_price_shipping = nil
    helper.free_shipping_limit = 60.0
    helper.config[:setDefaultPriceShippingAlways] = false
    helper.config[:setDefaultPriceShippingIfEmpty] = false

    version = {price_shipping_text: "", price_text: ""}
    helper.process_price_shipping version
    assert_equal "", version[:price_shipping_text]

    text = "3 € 50"
    version = {price_shipping_text: text, price_text: ""}
    helper.process_price_shipping version
    assert_equal text, version[:price_shipping_text]

    version = {price_shipping_text: "", price_text: "10 € 50"}
    helper.process_price_shipping version
    assert_equal "", version[:price_shipping_text]

    text = "3 € 50"
    version = {price_shipping_text: text, price_text: "10 € 50"}
    helper.process_price_shipping version
    assert_equal text, version[:price_shipping_text]

    version = {price_shipping_text: "", price_text: "60 € 50"}
    helper.process_price_shipping version
    assert_equal MerchantHelper::FREE_PRICE, version[:price_shipping_text]

    text = "3 € 50"
    version = {price_shipping_text: text, price_text: "60 € 50"}
    helper.process_price_shipping version
    assert_equal MerchantHelper::FREE_PRICE, version[:price_shipping_text]
  end

  test "it should process_price_shipping with default-ifempty-free and without always" do
    helper = MerchantHelper.new
    helper.default_price_shipping = "4 € 50"
    helper.free_shipping_limit = 60.0
    helper.config[:setDefaultPriceShippingAlways] = false
    helper.config[:setDefaultPriceShippingIfEmpty] = true

    version = {price_shipping_text: "", price_text: ""}
    helper.process_price_shipping version
    assert_equal helper.default_price_shipping, version[:price_shipping_text]

    text = "3 € 50"
    version = {price_shipping_text: text, price_text: ""}
    helper.process_price_shipping version
    assert_equal text, version[:price_shipping_text]

    version = {price_shipping_text: "", price_text: "10 € 50"}
    helper.process_price_shipping version
    assert_equal helper.default_price_shipping, version[:price_shipping_text]

    text = "3 € 50"
    version = {price_shipping_text: text, price_text: "10 € 50"}
    helper.process_price_shipping version
    assert_equal text, version[:price_shipping_text]

    version = {price_shipping_text: "", price_text: "60 € 50"}
    helper.process_price_shipping version
    assert_equal MerchantHelper::FREE_PRICE, version[:price_shipping_text]

    text = "3 € 50"
    version = {price_shipping_text: text, price_text: "60 € 50"}
    helper.process_price_shipping version
    assert_equal MerchantHelper::FREE_PRICE, version[:price_shipping_text]
  end

  test "it should process_price_shipping with default-always-free and without ifempty" do
    helper = MerchantHelper.new
    helper.default_price_shipping = "4 € 50"
    helper.free_shipping_limit = 60.0
    helper.config[:setDefaultPriceShippingAlways] = true
    helper.config[:setDefaultPriceShippingIfEmpty] = false

    version = {price_shipping_text: "", price_text: ""}
    helper.process_price_shipping version
    assert_equal helper.default_price_shipping, version[:price_shipping_text]

    text = "3 € 50"
    version = {price_shipping_text: text, price_text: ""}
    helper.process_price_shipping version
    assert_equal helper.default_price_shipping, version[:price_shipping_text]

    version = {price_shipping_text: "", price_text: "10 € 50"}
    helper.process_price_shipping version
    assert_equal helper.default_price_shipping, version[:price_shipping_text]

    text = "3 € 50"
    version = {price_shipping_text: text, price_text: "10 € 50"}
    helper.process_price_shipping version
    assert_equal helper.default_price_shipping, version[:price_shipping_text]

    version = {price_shipping_text: "", price_text: "60 € 50"}
    helper.process_price_shipping version
    assert_equal MerchantHelper::FREE_PRICE, version[:price_shipping_text]

    text = "3 € 50"
    version = {price_shipping_text: text, price_text: "60 € 50"}
    helper.process_price_shipping version
    assert_equal MerchantHelper::FREE_PRICE, version[:price_shipping_text]
  end

  test "it should process_price_shipping with default-always-ifempty-free" do
    helper = MerchantHelper.new
    helper.default_price_shipping = "4 € 50"
    helper.free_shipping_limit = 60.0
    helper.config[:setDefaultPriceShippingAlways] = true
    helper.config[:setDefaultPriceShippingIfEmpty] = true

    version = {price_shipping_text: "", price_text: ""}
    helper.process_price_shipping version
    assert_equal helper.default_price_shipping, version[:price_shipping_text]

    text = "3 € 50"
    version = {price_shipping_text: text, price_text: ""}
    helper.process_price_shipping version
    assert_equal helper.default_price_shipping, version[:price_shipping_text]

    version = {price_shipping_text: "", price_text: "10 € 50"}
    helper.process_price_shipping version
    assert_equal helper.default_price_shipping, version[:price_shipping_text]

    text = "3 € 50"
    version = {price_shipping_text: text, price_text: "10 € 50"}
    helper.process_price_shipping version
    assert_equal helper.default_price_shipping, version[:price_shipping_text]

    version = {price_shipping_text: "", price_text: "60 € 50"}
    helper.process_price_shipping version
    assert_equal MerchantHelper::FREE_PRICE, version[:price_shipping_text]

    text = "3 € 50"
    version = {price_shipping_text: text, price_text: "60 € 50"}
    helper.process_price_shipping version
    assert_equal MerchantHelper::FREE_PRICE, version[:price_shipping_text]
  end

  test "it should process_shipping_info without default-always-ifempty-before-after" do
    helper = MerchantHelper.new
    helper.default_shipping_info = nil # "Par colissiomo."
    helper.config[:setDefaultShippingInfoIfEmpty] = false
    helper.config[:setDefaultShippingInfoAlways] = false
    helper.config[:addDefaultShippingInfoBefore] = false
    helper.config[:addDefaultShippingInfoAfter] = false

    version = {shipping_info: ""}
    helper.process_shipping_info version
    assert_equal "", version[:shipping_info]

    text = "Bientôt"
    version = {shipping_info: text}
    helper.process_shipping_info version
    assert_equal text, version[:shipping_info]
  end

  test "it should process_shipping_info with default-always and without ifempty-before-after" do
    helper = MerchantHelper.new
    helper.default_shipping_info = "Par colissiomo."
    helper.config[:setDefaultShippingInfoIfEmpty] = false
    helper.config[:setDefaultShippingInfoAlways] = true
    helper.config[:addDefaultShippingInfoBefore] = false
    helper.config[:addDefaultShippingInfoAfter] = false

    version = {shipping_info: ""}
    helper.process_shipping_info version
    assert_equal helper.default_shipping_info, version[:shipping_info]

    version = {shipping_info: "Bientôt"}
    helper.process_shipping_info version
    assert_equal helper.default_shipping_info, version[:shipping_info]
  end

  test "it should process_shipping_info with default-ifempty and without always-before-after" do
    helper = MerchantHelper.new
    helper.default_shipping_info = "Par colissiomo."
    helper.config[:setDefaultShippingInfoIfEmpty] = true
    helper.config[:setDefaultShippingInfoAlways] = false
    helper.config[:addDefaultShippingInfoBefore] = false
    helper.config[:addDefaultShippingInfoAfter] = false

    version = {shipping_info: ""}
    helper.process_shipping_info version
    assert_equal helper.default_shipping_info, version[:shipping_info]

    text = "Bientôt"
    version = {shipping_info: text}
    helper.process_shipping_info version
    assert_equal text, version[:shipping_info]
  end

  test "it should process_shipping_info with default-ifempty-always and without before-after" do
    helper = MerchantHelper.new
    helper.default_shipping_info = "Par colissiomo."
    helper.config[:setDefaultShippingInfoIfEmpty] = true
    helper.config[:setDefaultShippingInfoAlways] = true
    helper.config[:addDefaultShippingInfoBefore] = false
    helper.config[:addDefaultShippingInfoAfter] = false

    version = {shipping_info: ""}
    helper.process_shipping_info version
    assert_equal helper.default_shipping_info, version[:shipping_info]

    text = "Bientôt"
    version = {shipping_info: text}
    helper.process_shipping_info version
    assert_equal helper.default_shipping_info, version[:shipping_info]
  end

  test "it should process_shipping_info with default-ifempty-before and without always-after" do
    helper = MerchantHelper.new
    helper.default_shipping_info = "Par colissiomo."
    helper.config[:setDefaultShippingInfoIfEmpty] = true
    helper.config[:setDefaultShippingInfoAlways] = false
    helper.config[:addDefaultShippingInfoBefore] = true
    helper.config[:addDefaultShippingInfoAfter] = false

    version = {shipping_info: ""}
    helper.process_shipping_info version
    assert_equal helper.default_shipping_info, version[:shipping_info]

    text = "Bientôt"
    version = {shipping_info: text}
    helper.process_shipping_info version
    assert_equal helper.default_shipping_info + text, version[:shipping_info]
  end

  test "it should process_shipping_info with default-ifempty-after and without always-before" do
    helper = MerchantHelper.new
    helper.default_shipping_info = "Par colissiomo."
    helper.config[:setDefaultShippingInfoIfEmpty] = true
    helper.config[:setDefaultShippingInfoAlways] = false
    helper.config[:addDefaultShippingInfoBefore] = false
    helper.config[:addDefaultShippingInfoAfter] = true

    version = {shipping_info: ""}
    helper.process_shipping_info version
    assert_equal helper.default_shipping_info, version[:shipping_info]

    text = "Bientôt"
    version = {shipping_info: text}
    helper.process_shipping_info version
    assert_equal text + helper.default_shipping_info, version[:shipping_info]
  end

  test "it should process_shipping_info with default-always-after and without ifempty-before" do
    helper = MerchantHelper.new
    helper.default_shipping_info = "Par colissiomo."
    helper.config[:setDefaultShippingInfoIfEmpty] = false
    helper.config[:setDefaultShippingInfoAlways] = true
    helper.config[:addDefaultShippingInfoBefore] = false
    helper.config[:addDefaultShippingInfoAfter] = true

    version = {shipping_info: ""}
    helper.process_shipping_info version
    assert_equal helper.default_shipping_info, version[:shipping_info]

    version = {shipping_info: "Bientôt"}
    helper.process_shipping_info version
    assert_equal helper.default_shipping_info, version[:shipping_info]
  end

  test "it should process_image_url without sub-imagesonly" do
    helper = MerchantHelper.new
    helper.image_sub = nil
    helper.config[:subImagesOnly] = false

    url = "http://www.mondomain.com/image_moyenne.jpg"
    version = {image_url: url}
    helper.process_image_url version
    assert_equal url, version[:image_url]
  end

  test "it should process_image_url with sub without imagesonly" do
    helper = MerchantHelper.new
    helper.image_sub = [/(?<=image_)\w+(?=\.jpg$)/i, "grande"]
    helper.config[:subImagesOnly] = false

    version = {image_url: "http://www.mondomain.com/image_moyenne.jpg"}
    helper.process_image_url version
    assert_equal "http://www.mondomain.com/image_grande.jpg", version[:image_url]
  end

  test "it should process_image_url with sub-imagesonly" do
    helper = MerchantHelper.new
    helper.image_sub = [/(?<=image_)\w+(?=\.jpg$)/i, "grande"]
    helper.config[:subImagesOnly] = true

    url = "http://www.mondomain.com/image_moyenne.jpg"
    version = {image_url: url}
    helper.process_image_url version
    assert_equal url, version[:image_url]
  end

  test "it shouldn't process_images when nil or empty" do
    helper = MerchantHelper.new
    helper.image_sub = [/(?<=image_)\w+(?=\.jpg$)/i, "grande"]

    version = {images: nil}
    version = helper.process_images(version)
    assert_nil version[:images]

    version = {images: []}
    version = helper.process_images(version)
    assert_equal [], version[:images]
  end

  test "it should process_images without sub-imageurlonly" do
    helper = MerchantHelper.new
    helper.image_sub = nil
    helper.config[:subImageUrlOnly] = false

    url = ["http://www.mondomain.com/image_petite.jpg"]
    version = {images: url}
    helper.process_images version
    assert_equal url, version[:images]
  end

  test "it should process_images with sub without imageurlonly" do
    helper = MerchantHelper.new
    helper.image_sub = [/(?<=image_)\w+(?=\.jpg$)/i, "grande"]
    helper.config[:subImageUrlOnly] = false

    version = {images: ["http://www.mondomain.com/image_petite.jpg"]}
    helper.process_images version
    assert_equal ["http://www.mondomain.com/image_grande.jpg"], version[:images]
  end

  test "it should process_images with sub-imageurlonly" do
    helper = MerchantHelper.new
    helper.image_sub = [/(?<=image_)\w+(?=\.jpg$)/i, "grande"]
    helper.config[:subImageUrlOnly] = true

    url = ["http://www.mondomain.com/image_petite.jpg"]
    version = {images: url}
    helper.process_images version
    assert_equal url, version[:images]
  end

  test "it shouldn't process_options if text is set" do
    helper = MerchantHelper.new
    text = "Blanc"
    version = {option1: {"style" => "background: FFFFFF;", "text" => text, "src" => ""}}

    for option in [nil, 0, 1, [1]]
      helper.config[:searchBackgroundImageOrColorForOptions] = option
      version = helper.process_options(version)
      assert_equal text, version[:option1]["text"], "with option #{option.inspect}"
    end
  end

  test "it shouldn't process_options if url is set" do
    helper = MerchantHelper.new
    url = "http://www.mondomain.com/image.jpg"
    version = {option1: {"style" => "background: FFFFFF;", "text" => "", "src" => url}}

    for option in [nil, 0, 1, [1]]
      helper.config[:searchBackgroundImageOrColorForOptions] = option
      version = helper.process_options(version)
      assert_equal "", version[:option1]["text"], "with option #{option.inspect}"
    end
  end

  test "it shouldn't process_options if bad option" do
    helper = MerchantHelper.new
    version = {option1: {"style" => "background: FFFFFF;", "text" => "", "src" => ""}}

    for option in [nil, 0, 2, [2]]
      helper.config[:searchBackgroundImageOrColorForOptions] = option
      version = helper.process_options(version)
      assert_equal "", version[:option1]["text"], "with option #{option.inspect}"
    end
  end

  test "it should process_options if good option" do
    helper = MerchantHelper.new

    version = {option1: {"style" => "background: FFFFFF;", "text" => "", "src" => ""}}
    for option in [1, [1], [1,2]]
      helper.config[:searchBackgroundImageOrColorForOptions] = option
      version = helper.process_options(version)
      assert_equal "FFFFFF", version[:option1]["text"], "with option #{option.inspect}"
    end

    version = {option1: {"style" => "background: #F60409;", "text" => "", "src" => ""}}
    for option in [1, [1], [1,2]]
      helper.config[:searchBackgroundImageOrColorForOptions] = option
      version = helper.process_options(version)
      assert_equal "#F60409", version[:option1]["text"], "with option #{option.inspect}"
    end

    version = {option1: {"style" => "background: url(http://ecx.images-amazon.com/images/I/419HBFeRvqL.jpg );", "text" => "", "src" => ""}}
    for option in [1, [1], [1,2]]
      helper.config[:searchBackgroundImageOrColorForOptions] = option
      version = helper.process_options(version)
      assert_equal "http://ecx.images-amazon.com/images/I/419HBFeRvqL.jpg ", version[:option1]["src"], "with option #{option.inspect}"
    end

    version = {option1: {"style" => "background-color:#c6865a;", "text" => "", "src" => ""}}
    for option in [1, [1], [1,2]]
      helper.config[:searchBackgroundImageOrColorForOptions] = option
      version = helper.process_options(version)
      assert_equal "#c6865a", version[:option1]["text"], "with option #{option.inspect}"
    end

    version = {option1: {"style" => "background-image: url(http://ecx.images-amazon.com/images/I/419HBFeRvqL.jpg );", "text" => "", "src" => ""}}
    for option in [1, [1], [1,2]]
      helper.config[:searchBackgroundImageOrColorForOptions] = option
      version = helper.process_options(version)
      assert_equal "http://ecx.images-amazon.com/images/I/419HBFeRvqL.jpg ", version[:option1]["src"], "with option #{option.inspect}"
    end
  end

  test "it should process (1)" do
    helper = MerchantHelper.new

    helper.default_price_shipping = "3 € 50"
    helper.default_shipping_info = "Par Colissimo sous 3 jours."
    helper.free_shipping_limit = 50.0
    helper.image_sub = [/(?<=image_)\w+(?=\.jpg$)/i, "grande"]

    helper.config = {
      setAvailableIfEmpty: true,
      setUnavailableIfEmpty: false,

      setDefaultPriceShippingIfEmpty: true,
      setDefaultPriceShippingAlways: false,

      setDefaultShippingInfoIfEmpty: true,
      setDefaultShippingInfoAlways: false,
      addDefaultShippingInfoBefore: true,
      addDefaultShippingInfoAfter: false,

      subImageUrlOnly: false,
      subImagesOnly: false,

      searchBackgroundImageOrColorForOptions: 1,
    }

    version = {
      availability_text: "Rupture de stock",
      price_text: "10 € 50",
      price_shipping_text: "2 € 90",
      shipping_info: "Peut nécessiter 2 jours supplémentaires.",
      image_url: "http://www.mondomain.com/image_moyenne.jpg",
      images: ["http://www.mondomain.com/image_petite.jpg"],
      option1: {"style" => "background-color:#c6865a;"},
      option2: {"text" => "38"},
    }

    version = helper.process version
    assert_equal "Rupture de stock", version[:availability_text]
    assert_equal "10 € 50", version[:price_text]
    assert_equal "2 € 90", version[:price_shipping_text]
    assert_equal helper.default_shipping_info + "Peut nécessiter 2 jours supplémentaires.", version[:shipping_info]
    assert_equal "http://www.mondomain.com/image_grande.jpg", version[:image_url]
    assert_equal ["http://www.mondomain.com/image_grande.jpg"], version[:images]
    assert_equal "#c6865a", version[:option1]["text"]
    assert_equal "38", version[:option2]["text"]
  end

  test "it should process (2)" do
    helper = MerchantHelper.new

    helper.default_price_shipping = "3 € 50"
    helper.default_shipping_info = "Par Colissimo sous 3 jours."
    helper.free_shipping_limit = 50.0
    helper.image_sub = [/(?<=image_)\w+(?=\.jpg$)/i, "grande"]

    helper.config = {
      setAvailableIfEmpty: false,
      setUnavailableIfEmpty: false,

      setDefaultPriceShippingIfEmpty: true,
      setDefaultPriceShippingAlways: false,

      setDefaultShippingInfoIfEmpty: true,
      setDefaultShippingInfoAlways: false,
      addDefaultShippingInfoBefore: true,
      addDefaultShippingInfoAfter: false,

      subImageUrlOnly: true,
      subImagesOnly: false,

      searchBackgroundImageOrColorForOptions: 1,
    }

    version = {
      availability_text: "",
      price_text: "60 € 50",
      price_shipping_text: "2 € 90",
      shipping_info: "",
      image_url: "http://www.mondomain.com/image_moyenne.jpg",
      images: ["http://www.mondomain.com/image_petite.jpg"],
      option1: {"style" => "background-color:#c6865a;"},
      option2: {"style" => "background-color:#c6865a;"},
    }

    version = helper.process version
    assert_equal "", version[:availability_text]
    assert_equal "60 € 50", version[:price_text]
    assert_equal MerchantHelper::FREE_PRICE, version[:price_shipping_text]
    assert_equal helper.default_shipping_info, version[:shipping_info]
    assert_equal "http://www.mondomain.com/image_grande.jpg", version[:image_url]
    assert_equal ["http://www.mondomain.com/image_petite.jpg"], version[:images]
    assert_equal "#c6865a", version[:option1]["text"]
    assert_equal "", version[:option2]["text"].to_s
  end
end