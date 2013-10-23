# -*- encoding : utf-8 -*-

module AlgoliaFeed

  class PriceMinister < AlgoliaFeed

    def initialize(params={})
      super

      self.urls = params[:urls] || [
        "ftp://prixing:j5Z61eg@priceminister.effiliation.com/prixing_BOOKS_TOP.xml.zip",
        "http://priceminister.effiliation.com/output/commun/effiliation_JARDIN_NEW.xml.gz",
        "http://priceminister.effiliation.com/output/commun/effiliation_CLOTHING_NEW.xml.gz",
        "http://priceminister.effiliation.com/output/commun/effiliation_COMPUTER_NEW.xml.gz",
        "http://priceminister.effiliation.com/output/commun/effiliation_GAMES_NEW.xml.gz",
        "http://priceminister.effiliation.com/output/commun/effiliation_BABY_NEW.xml.gz",
        "http://priceminister.effiliation.com/output/commun/effiliation_HIFI_NEW.xml.gz",
        "http://priceminister.effiliation.com/output/commun/effiliation_WHITE_NEW.xml.gz",
        "http://priceminister.effiliation.com/output/commun/effiliation_VIDEO_NEW.xml.gz",
        "ftp://prixing:j5Z61eg@priceminister.effiliation.com/prixing_MUSIC_TOP.xml.zip",
        "http://priceminister.effiliation.com/output/commun/effiliation_SPORT_NEW.xml.gz",
        "http://priceminister.effiliation.com/output/commun/effiliation_ELECTRONICS_NEW.xml.gz"
      ]

      self.product_field = params[:product_field] || 'produit'

#      self.index_name = params[:index_name] || 'priceminister'

      self.conversions = params[:conversions] || {
        'codebarre'       => 'ean',
        'prix'            => 'price',
        'urlficheproduit' => 'product_url',
        'fraisdeport'     => 'shipping_price',
        'dateexpedition'  => 'shipping_info',
        'nomproduit'      => 'name',
        'urlimage'        => 'image_url',
        'nomfournisseur'  => 'brand',
        'stock'           => 'availability'
      }
    end

    def canonize_url(url)
      matches = /url=(http:\/\/www.priceminister.com\/offer\/buy\/\d+)/.match(url)
      return matches[1] if matches.present?
      url
    end

    def process_product(product)
      record = super
      raise RejectedRecord, "Invalid image #{record['image_url']}" if record['image_url'] =~ /(noavailableimage|generiques)/
      record['image_url'].gsub!(/_S\./i, "_L.")
      record['name'] = record['name'].gsub(/\A\!\[Cdata\[ /,'').gsub(/\s+\]\]\Z/, '')
      record['price'] = (record['price'].to_f * 100).to_i.to_s
      record['shipping_price'] = (record['shipping_price'].to_f * 100).to_i.to_s
      record['currency'] = 'EUR'
      categories = get_categories([product['categorie'], product['souscategorie'], product['souscategorie2'], product['souscategorie3']])
      categories.each do |c|
        record['_tags'] << "category:#{c}"
      end
      record['category'] = categories.join(' > ')
      record
    end  
  end
end

