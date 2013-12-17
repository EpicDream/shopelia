# -*- encoding : utf-8 -*-
class PriceministerCom

  AVAILABILITY_HASH = {
    /\(0\)/i => false,
    /\([1-9]\d*\)/i => true,
    /^\d+ occasions?$/i => false,
    /^\d+ collections?$/i => false,
    /^\d+ neuf/i => true,

    /[\d\s]+ r.sultat/i => false, # Redirection vers recherche quand trouve pas.
    "Aucun resultat" => false,

    "Top Ventes" => false, # rediriger sur l'accueil
    "Les produits les plus vus du moment dans" => true,
    "Les articles les plus vus du moment" => true,
    "Les PriceMembers ayant vu" => true,
    "Les produits frequemment achetes ensemble" => true,
    "Votre historique recent" => true,
    /Les produits de '.*?' avec les meilleurs avis/i => true,
  }

  def initialize url
    @url = url
  end

  def monetize
    "http://track.effiliation.com/servlet/effi.redir?id_compteur=12712494&url=" + CGI::escape(@url.gsub(/#.*$/, ""))
  end

  def canonize
    matches = /(http:\/\/www.priceminister.com\/offer\/buy\/\d+)/.match(@url)
    return matches[1] if matches.present?
    @url
  end

  def process_availability version
    version[:availability_text] = MerchantHelper::AVAILABLE if version[:availability_text].blank?
    version
  end

  def process_image_url version
    version[:image_url].sub!(/_\w+\.(\w+)$/, '.\\1') if version[:image_url].present?
    version
  end

  def process_images version
    return version unless version[:images].kind_of?(Array)
    version[:images].map! { |url| url.sub(/_\w+\.(\w+)$/, '.\\1') }
    version
  end
end
