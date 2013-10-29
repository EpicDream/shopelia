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

      self.conversions = params[:conversions] || {
        'codebarre'       => 'ean',
        'prix'            => 'price',
        'urlficheproduit' => 'product_url',
        'fraisdeport'     => 'price_shipping',
        'dateexpedition'  => 'shipping_info',
        'nomproduit'      => 'name',
        'urlimage'        => 'image_url',
        'nomfournisseur'  => 'brand',
        'stock'           => 'availability',
        'TOP100'          => 'rank'
      }

      self.category_fields = params[:category_fields] || ['categorie', 'souscategorie', 'souscategorie2', 'souscategorie3' ]

    end

    def canonize(url)
      if m = url.match(/(http:\/\/www\.priceminister\.com\/offer\/buy\/\d+)/)
        return m[1]
      else
        return Linker.clean(url)
      end
    end

    def process_product(product)
      record = super

      raise RejectedRecord.new("Invalid image #{record['image_url']}", :rejected_img) if record['image_url'] =~ /(noavailableimage|generiques)/
      record['image_url'].gsub!(/_S\./i, "_L.") if (record.has_key?('image_url') and record['image_url'] =~ /\Ahttp/)

      record['name'] = record['name'].gsub(/\A\!\[Cdata\[ /,'').gsub(/\s+\]\]\Z/, '')

      record['price'] = to_cents(record['price'])
      record['price_shipping'] = to_cents(record['price_shipping'])

      record.delete('rank') if record['rank'] == 0

      record
    end  
  end
end

