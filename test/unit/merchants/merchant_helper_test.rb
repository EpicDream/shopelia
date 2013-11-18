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
      "4.0 étoiles sur 5"]
    array.each do |str|
      assert_equal 4.0, MerchantHelper.parse_rating(str)
    end

    array = [ "3.5", "3.5/5", "(3.5/5)",
      "3.5 / 5", "(3.5 / 5)",
      "3.5 étoiles sur 5"]
    array.each do |str|
      assert_equal 3.5, MerchantHelper.parse_rating(str)
    end
  end

  test "it should parse_availability to true" do
    assert_equal true, MerchantHelper.parse_availability(MerchantHelper::AVAILABLE)

    array = [ "en stock", "8 offres", "en vente sur", "Précommandez maintenant pour réserver votre Kindle Paperwhite.",
              "Expédié habituellement sous 2 à 3 semaines", "Peu de stock", "Stock modéré",
              "disponible sous 4 semaines", "Seulement 1 en stock", "in stock but may require an extra 1-2 days to process.",
              "Conditions spéciales :- livraison : 10 semaines", "livraison des fichiers", "attention : dernières pièces disponibles",
              "In stock", "Available for Immediate Shipment.", "Please allow 4-6 weeks for delivery.", "expected ship date",
              "disponible", "Délai 3 à 5 jours", "1 article disponible" ]
    array.each do |str|
      assert_equal true, MerchantHelper.parse_availability(str)
    end
  end

  test "it should parse_availability to false" do
    assert_equal false, MerchantHelper.parse_availability(MerchantHelper::UNAVAILABLE)

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
              "Erreur: Désolé, mais le produit que vous avez demandé n'a pas été trouvé !" ]
    array.each do |str|
      assert_equal false, MerchantHelper.parse_availability(str)
    end
  end

  test "it should parse_availability to nil" do
    array = [ "35 €", "Vert", "Peut être qu'il est dispo, peut être pas", "Erreur 500" ]
    array.each do |str|
      assert_equal nil, MerchantHelper.parse_availability(str)
    end
  end
end