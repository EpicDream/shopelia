# -*- encoding : utf-8 -*-

module AlgoliaFeed

  class TradedoublerFiler < FileUtils

    def initialize(params={})
      super

      self.urls = params[:urls] || ['http://pf.tradedoubler.com/export/export?myFeed=13832248012299963&myFormat=13832248012299963']
      self.parser_class = params[:parser_class] || 'AlgoliaFeed::Tradedoubler'
      self.rejected_files = params[:rejected_files] || ['feed_15992.xml' , 'feed_17385.xml', 'feed_11034.xml', 'feed_21226.xml']
    end
  end

  class Tradedoubler < XmlParser

    def initialize(params={})
      super

      self.conversions = params[:conversions] || {
        'name'         => 'name',
        'productUrl'   => 'product_url',
        'imageUrl'     => 'image_url',
        'description ' => 'description',
        'currency'     => 'currency',
        'availability' => 'availability',
        'ean'          => 'ean',
        'brand'        => 'brand',
        'reference'    => 'reference',
        'price'        => 'price',
        'shippingCost' => 'price_shipping',
        'deliveryTime' => 'shipping_info',
      }

      self.category_fields = ['TDCategoryName', 'merchantCategoryName']
      params[:parser_class] = self.class
      self.filer = TradedoublerFiler.new(params)
      self
    end

    def process_product(product)
      record = super

      record['price'] = to_cents(record['price'])
      record['price_shipping'] = to_cents(record['price_shipping'])

      record.delete('brand') if record['brand'] == 'NONAME'

      if record['merchant_name'] == 'Rue du Commerce'
        record['image_url'].gsub!(/\/large\//, '/xl/')
        record['image_url'].gsub!(/150x150\.jpg/, '300x300.jpg')
      end

      record
    end

# require 'algolia/algolia_feed'
# x = AlgoliaFeed::Tradedoubler.new(tmpdir:'/var/lib/db/algolia', debug:1, index_name: 'tradedoubler')
# x.process_directory

  end
end

