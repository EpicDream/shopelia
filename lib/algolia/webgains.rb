# -*- encoding : utf-8 -*-

module AlgoliaFeed

  class WebgainsFiler < FileUtils

    def initialize(params={})
      super

      self.urls = params[:urls] || ['http://content.webgains.com/affiliates/datafeed.html?action=download&campaign=145659&username=shopelia&password=pichon69&format=xml&zipformat=gzip_notar&fields=extended&programs=all&allowedtags=all&categories=all']

      self.parser_class = params[:parser_class] || 'AlgoliaFeed::Webgains'
    end
  end

  class Webgains < XmlParser

    def initialize(params={})
      super

      self.conversions = params[:conversions] || {
        'product_name'    => 'name',
        'price'           => 'price',
        'deeplink'        => 'product_url',
        'description '    => 'description',
        'image_url'       => 'image_url',
        'currency'        => 'currency',
        'in_stock'        => 'availability',
        'barcode'         => 'ean',
        'brand'           => 'brand',
        'reference'       => 'reference',
        'delivery_cost'   => 'price_shipping',
        'delivery_period' => 'shipping_info',
        'Author'          => 'author'
      }

      self.category_fields = ['categories', 'merchant_category']

      params[:parser_class] = self.class
      self.filer = WebgainsFiler.new(params)
      self
    end

   # def set_categories

   # end

    def process_product(product)
      record = super

      record['price'] = to_cents(record['price'])
      record['price_shipping'] = to_cents(record['price_shipping'])

      record
    end

  end
end

