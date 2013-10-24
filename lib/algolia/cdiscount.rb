# -*- encoding : utf-8 -*-

module AlgoliaFeed

  class Cdiscount < AlgoliaFeed

    def initialize(params={})
      super

      self.urls = params[:urls] || ['http://pf.tradedoubler.com/export/export?myFeed=13692964912238732&myFormat=13692964912238732']

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
        'shippingCost' => 'shipping_price',
        'deliveryTime' => 'shipping_info',
      }

      self.category_fields = ['TDCategoryName', 'merchantCategoryName']

    end

    def process_product(product)
      record = super

      record['price'] = to_cents(record['price'])
      record['shipping_price'] = to_cents(record['shipping_price'])

      record
    end
  end
end

