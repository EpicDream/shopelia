# -*- encoding : utf-8 -*-

module AlgoliaFeed

  class PublicideesFiler < Filer

    require 'nokogiri'

    attr_accessor :meta_url, :rejected_feeds

    def download
      self.urls = []
      meta_file = download_url(self.meta_url)
      File.open(meta_file, 'rb') do |f|
        reader = Nokogiri::XML::Reader(f) { |config| config.nonet.noblanks }
        reader.each do |r|
          next unless r.name == 'global_feed' && r.node_type == Nokogiri::XML::Reader::TYPE_ELEMENT
          url = Nokogiri::XML(r.outer_xml).text
          if m = /progid=(\d+)/.match(url)
            next if self.rejected_feeds.include?(m[1])
          end
          self.urls << url if url.size > 0 and url =~ /\Ahttp:/
        end
      end
      File.unlink(meta_file)
      super
    end

    def initialize(params={})
      super

      self.meta_url = 'http://affilie.publicidees.com/xmlProgAff.php?partid=37027&key=487bba1ccb0e433d1c3a18d02936e817'
      self.rejected_feeds = ['1981', '2970']
      self.parser_class = params[:parser_class] || 'AlgoliaFeed::Publicidees'
    end
  end

  class Publicidees < XmlParser

    def initialize(params={})
      super

      self.conversions = params[:conversions] || {
        'title'                                => 'name',
        'desc'                                 => 'description',
        'full_desc'                            => 'full_desc',
        'product_id/ean'                       => 'ean',
        'price-currency=EUR'                   => 'price',
        'url'                                  => 'product_url',
        'shipping/price-currency=EUR'          => 'price_shipping_with_currency',
        'shipping/price'                       => 'price_shipping',
        'shipping/delivery'                    => 'shipping_info',
        'product_images/image-type=default'    => 'image_url',
        'product_id/ean'                       => 'ean',
        'trademark'                            => 'brand',
        'storeData/data-type=Produit en stock' => 'availability',
        'product_id/manufacturer'              => 'manufacturer'
      }

      self.category_fields = ['category/merchant/name', 'storeData/Categories', 'storeData/data-type=Sous_Categorie', 'storeData/data-type=Sous_Famille', 'storeData/Sub_category1', 'storeData/Sub_category2']

      params[:parser_class] = self.class
      self.filer = PublicideesFiler.new(params)
      self
    end

    def process_product(product)
      record = super

      record['price'] = to_cents(record['price'])
      record['price_shipping'] = to_cents(record['price_shipping'])

      record['availability'] = 'En stock' if record['availability'] == 'oui'

      if record.has_key?('manufacturer')
        record['brand'] = record['manufacturer'] unless record.has_key?('brand')
        record.delete('manufacturer')
      end

      if record.has_key?('full_desc')
        record['description'] = record['full_desc'] unless record.has_key?('description')
        record.delete('full_desc')
      end

      if record.has_key?('price_shipping_with_currency')
        record['price_shipping'] = record['price_shipping_with_currency'] unless record.has_key?('price_shipping')
        record.delete('price_shipping_with_currency')
      end

      record
    end

  end
end

