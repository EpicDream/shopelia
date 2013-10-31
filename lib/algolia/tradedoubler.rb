# -*- encoding : utf-8 -*-

module AlgoliaFeed

  class Tradedoubler < AlgoliaFeed

    def initialize(params={})
      super

      self.urls = params[:urls] || ['http://pf.tradedoubler.com/export/export?myFeed=13826125592299963&myFormat=13826125592299963']

# ['http://pf.tradedoubler.com/export/export?myFeed=13692964912238732&myFormat=13692964912238732'] Cdiscount

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

      self.rejected_files = params[:rejected_files] || ['feed_15992.xml' , 'feed_17385.xml', 'feed_11034.xml', 'feed_21226.xml']

    end

    def process_product(product)
      record = super

      record['price'] = to_cents(record['price'])
      record['price_shipping'] = to_cents(record['price_shipping'])

      record.delete('brand') if record['brand'] == 'NONAME'

      record
    end

# require 'algolia/algolia_feed'
# x = AlgoliaFeed::Tradedoubler.new(tmpdir:'/var/lib/db/algolia', debug:1, index_name: 'tradedoubler')
# x.process_directory

  end
end

