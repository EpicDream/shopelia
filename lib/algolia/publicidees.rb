# -*- encoding : utf-8 -*-

module AlgoliaFeed

  class PublicideesFiler < Filer

    require 'nokogiri'

    attr_accessor :meta_url

    def download
      self.urls = []
#      meta_file = download_url(self.meta_url)
      meta_file = '/var/lib/db/algolia/AlgoliaFeed::Publicidees/xml.xml'
      File.open(meta_file, 'rb') do |f|
        reader = Nokogiri::XML::Reader(f) { |config| config.nonet.noblanks }
        reader.each do |r|
          next unless r.name == 'global_feed' && r.node_type == Nokogiri::XML::Reader::TYPE_ELEMENT
          url = Nokogiri::XML(r.outer_xml).text
          self.urls << url if url.size > 0 and url =~ /\Ahttp:/
        end
      end
#      unlink(meta_file)
      puts self.urls
    end

    def initialize(params={})
      super

      self.meta_url = 'http://affilie.publicidees.com/xmlProgAff.php?partid=37027&key=487bba1ccb0e433d1c3a18d02936e817'

      self.parser_class = params[:parser_class] || 'AlgoliaFeed::Publicidees'
    end
  end

  class Publicidees < XmlParser

    def initialize(params={})
      super

      self.conversions = params[:conversions] || {
        'title'                                => 'name',
        'desc'                                 => 'description',
        'price-currency=EUR'                   => 'price',
        'url'                                  => 'product_url',
        'shipping/price'                       => 'price_shipping',
        'shipping/delivery'                    => 'shipping_info',
        'product_images/image-type=default'    => 'image_url',
        'product_id/ean'                       => 'ean',
        'trademark'                            => 'brand',
        'storeData/data-type=Produit en stock' => 'availability'
      }

      self.category_fields = ['category/merchant/name']

      params[:parser_class] = self.class
      self.filer = WebgainsFiler.new(params)
      self
    end

    def process_product(product)
      record = super

      record['price'] = to_cents(record['price'])
      record['price_shipping'] = to_cents(record['price_shipping'])

      record['availability'] = 'En stock' if record['availability'] == 'oui'

      record
    end

  end
end

