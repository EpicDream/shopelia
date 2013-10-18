# -*- encoding : utf-8 -*-

module AlgoliaFeed

  class PriceMinister < AlgoliaFeed

    def initialize
      super

      self.urls = [
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

      self.product_field = 'produit'
      self.batch_size = 1000

      self.conversions = {
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
    begin
      record = super
      record['name'] = record['name'].gsub(/\A\!\[Cdata\[ /,'').gsub(/\s+\]\]\Z/, '')
      record['price'] = (record['price'].to_f * 100).to_i.to_s
      record['shipping_price'] = (record['shipping_price'].to_f * 100).to_i.to_s
      record['currency'] = 'EUR'
      record['_tags'] = [] unless record.has_key?('_tags')
      categories = []
      categories << product.search('categorie').text if product.search('categorie').text.size > 0
      categories << product.search('souscategorie').text if product.search('souscategorie').text.size > 0
      categories << product.search('souscategorie2').text if product.search('souscategorie2').text.size > 0
      categories << product.search('souscategorie3').text if product.search('souscategorie3').text.size > 0
      categories.each do |c|
        record['_tags'] << "category:#{c}"
      end
      record['category'] = categories.join('>')
      record['_tags'] << "merchant_name:Price Minister"
      record['product_url'] = canonize_url(record['product_url'])
      record['image_url'].gsub!(/_S\./i, "_L.")
      record.delete('image_url') if record['image_url'] =~ /noavailableimage/
      return unless record['image_url'] =~ /\S/
    rescue => e
#      puts "Failed record #{record.inspect}"
      return
    end  
      record
    end

  end

end

