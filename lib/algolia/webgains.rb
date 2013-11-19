# -*- encoding : utf-8 -*-

module AlgoliaFeed

  class WebgainsFiler < Filer

    def initialize(params={})
      super

      self.urls = params[:urls] || [
        'http://content.webgains.com/affiliates/datafeed.html?action=download&campaign=145659&username=shopelia&password=pichon69&format=xml&zipformat=gzip_notar&fields=extended&feeds=1839&allowedtags=all&categories=all',
        'http://content.webgains.com/affiliates/datafeed.html?action=download&campaign=145659&username=shopelia&password=pichon69&format=xml&zipformat=gzip_notar&fields=extended&feeds=4613&allowedtags=all&categories=all',
        'http://content.webgains.com/affiliates/datafeed.html?action=download&campaign=145659&username=shopelia&password=pichon69&format=xml&zipformat=gzip_notar&fields=extended&feeds=1614&allowedtags=all&categories=all',
        'http://content.webgains.com/affiliates/datafeed.html?action=download&campaign=145659&username=shopelia&password=pichon69&format=xml&zipformat=gzip_notar&fields=extended&feeds=3719&allowedtags=all&categories=all',
        'http://content.webgains.com/affiliates/datafeed.html?action=download&campaign=145659&username=shopelia&password=pichon69&format=xml&zipformat=gzip_notar&fields=extended&feeds=2939&allowedtags=all&categories=all',
        'http://content.webgains.com/affiliates/datafeed.html?action=download&campaign=145659&username=shopelia&password=pichon69&format=xml&zipformat=gzip_notar&fields=extended&feeds=2545&allowedtags=all&categories=all',
        'http://content.webgains.com/affiliates/datafeed.html?action=download&campaign=145659&username=shopelia&password=pichon69&format=xml&zipformat=gzip_notar&fields=extended&feeds=3977&allowedtags=all&categories=all',
        'http://content.webgains.com/affiliates/datafeed.html?action=download&campaign=145659&username=shopelia&password=pichon69&format=xml&zipformat=gzip_notar&fields=extended&feeds=1771&allowedtags=all&categories=all',
        'http://content.webgains.com/affiliates/datafeed.html?action=download&campaign=145659&username=shopelia&password=pichon69&format=xml&zipformat=gzip_notar&fields=extended&feeds=4681&allowedtags=all&categories=all',
        'http://content.webgains.com/affiliates/datafeed.html?action=download&campaign=145659&username=shopelia&password=pichon69&format=xml&zipformat=gzip_notar&fields=extended&feeds=1085&allowedtags=all&categories=all',
        'http://content.webgains.com/affiliates/datafeed.html?action=download&campaign=145659&username=shopelia&password=pichon69&format=xml&zipformat=gzip_notar&fields=extended&feeds=549&allowedtags=all&categories=all',
        'http://content.webgains.com/affiliates/datafeed.html?action=download&campaign=145659&username=shopelia&password=pichon69&format=xml&zipformat=gzip_notar&fields=extended&feeds=4329&allowedtags=all&categories=all',
        'http://content.webgains.com/affiliates/datafeed.html?action=download&campaign=145659&username=shopelia&password=pichon69&format=xml&zipformat=gzip_notar&fields=extended&feeds=4271&allowedtags=all&categories=all',
        'http://content.webgains.com/affiliates/datafeed.html?action=download&campaign=145659&username=shopelia&password=pichon69&format=xml&zipformat=gzip_notar&fields=extended&feeds=2772&allowedtags=all&categories=all',
        'http://content.webgains.com/affiliates/datafeed.html?action=download&campaign=145659&username=shopelia&password=pichon69&format=xml&zipformat=gzip_notar&fields=extended&feeds=4307&allowedtags=all&categories=all',
        'http://content.webgains.com/affiliates/datafeed.html?action=download&campaign=145659&username=shopelia&password=pichon69&format=xml&zipformat=gzip_notar&fields=extended&feeds=1289&allowedtags=all&categories=all',
        'http://content.webgains.com/affiliates/datafeed.html?action=download&campaign=145659&username=shopelia&password=pichon69&format=xml&zipformat=gzip_notar&fields=extended&feeds=1567&allowedtags=all&categories=all',
        'http://content.webgains.com/affiliates/datafeed.html?action=download&campaign=145659&username=shopelia&password=pichon69&format=xml&zipformat=gzip_notar&fields=extended&feeds=4041&allowedtags=all&categories=all',
        'http://content.webgains.com/affiliates/datafeed.html?action=download&campaign=145659&username=shopelia&password=pichon69&format=xml&zipformat=gzip_notar&fields=extended&feeds=3747&allowedtags=all&categories=all',
        'http://content.webgains.com/affiliates/datafeed.html?action=download&campaign=145659&username=shopelia&password=pichon69&format=xml&zipformat=gzip_notar&fields=extended&feeds=4273&allowedtags=all&categories=all',
        'http://content.webgains.com/affiliates/datafeed.html?action=download&campaign=145659&username=shopelia&password=pichon69&format=xml&zipformat=gzip_notar&fields=extended&feeds=4527&allowedtags=all&categories=all',
        'http://content.webgains.com/affiliates/datafeed.html?action=download&campaign=145659&username=shopelia&password=pichon69&format=xml&zipformat=gzip_notar&fields=extended&feeds=1370&allowedtags=all&categories=all',
        'http://content.webgains.com/affiliates/datafeed.html?action=download&campaign=145659&username=shopelia&password=pichon69&format=xml&zipformat=gzip_notar&fields=extended&feeds=2831&allowedtags=all&categories=all',
        'http://content.webgains.com/affiliates/datafeed.html?action=download&campaign=145659&username=shopelia&password=pichon69&format=xml&zipformat=gzip_notar&fields=extended&feeds=3431&allowedtags=all&categories=all',
        'http://content.webgains.com/affiliates/datafeed.html?action=download&campaign=145659&username=shopelia&password=pichon69&format=xml&zipformat=gzip_notar&fields=extended&feeds=4691&allowedtags=all&categories=all',
        'http://content.webgains.com/affiliates/datafeed.html?action=download&campaign=145659&username=shopelia&password=pichon69&format=xml&zipformat=gzip_notar&fields=extended&feeds=4429&allowedtags=all&categories=all',
        'http://content.webgains.com/affiliates/datafeed.html?action=download&campaign=145659&username=shopelia&password=pichon69&format=xml&zipformat=gzip_notar&fields=extended&feeds=3685&allowedtags=all&categories=all',
        'http://content.webgains.com/affiliates/datafeed.html?action=download&campaign=145659&username=shopelia&password=pichon69&format=xml&zipformat=gzip_notar&fields=extended&feeds=2696&allowedtags=all&categories=all',
        'http://content.webgains.com/affiliates/datafeed.html?action=download&campaign=145659&username=shopelia&password=pichon69&format=xml&zipformat=gzip_notar&fields=extended&feeds=3329&allowedtags=all&categories=all',
        'http://content.webgains.com/affiliates/datafeed.html?action=download&campaign=145659&username=shopelia&password=pichon69&format=xml&zipformat=gzip_notar&fields=extended&feeds=4731&allowedtags=all&categories=all',
        'http://content.webgains.com/affiliates/datafeed.html?action=download&campaign=145659&username=shopelia&password=pichon69&format=xml&zipformat=gzip_notar&fields=extended&feeds=2585&allowedtags=all&categories=all',
        'http://content.webgains.com/affiliates/datafeed.html?action=download&campaign=145659&username=shopelia&password=pichon69&format=xml&zipformat=gzip_notar&fields=extended&feeds=4245&allowedtags=all&categories=all',
        'http://content.webgains.com/affiliates/datafeed.html?action=download&campaign=145659&username=shopelia&password=pichon69&format=xml&zipformat=gzip_notar&fields=extended&feeds=1151&allowedtags=all&categories=all',
        'http://content.webgains.com/affiliates/datafeed.html?action=download&campaign=145659&username=shopelia&password=pichon69&format=xml&zipformat=gzip_notar&fields=extended&feeds=3991&allowedtags=all&categories=all',
        'http://content.webgains.com/affiliates/datafeed.html?action=download&campaign=145659&username=shopelia&password=pichon69&format=xml&zipformat=gzip_notar&fields=extended&feeds=2669&allowedtags=all&categories=all',
        'http://content.webgains.com/affiliates/datafeed.html?action=download&campaign=145659&username=shopelia&password=pichon69&format=xml&zipformat=gzip_notar&fields=extended&feeds=3793&allowedtags=all&categories=all',
        'http://content.webgains.com/affiliates/datafeed.html?action=download&campaign=145659&username=shopelia&password=pichon69&format=xml&zipformat=gzip_notar&fields=extended&feeds=3789&allowedtags=all&categories=all',
        'http://content.webgains.com/affiliates/datafeed.html?action=download&campaign=145659&username=shopelia&password=pichon69&format=xml&zipformat=gzip_notar&fields=extended&feeds=1462&allowedtags=all&categories=all',
        'http://content.webgains.com/affiliates/datafeed.html?action=download&campaign=145659&username=shopelia&password=pichon69&format=xml&zipformat=gzip_notar&fields=extended&feeds=3323&allowedtags=all&categories=all',
        'http://content.webgains.com/affiliates/datafeed.html?action=download&campaign=145659&username=shopelia&password=pichon69&format=xml&zipformat=gzip_notar&fields=extended&feeds=1879&allowedtags=all&categories=all',
        'http://content.webgains.com/affiliates/datafeed.html?action=download&campaign=145659&username=shopelia&password=pichon69&format=xml&zipformat=gzip_notar&fields=extended&feeds=3993&allowedtags=all&categories=all',
        'http://content.webgains.com/affiliates/datafeed.html?action=download&campaign=145659&username=shopelia&password=pichon69&format=xml&zipformat=gzip_notar&fields=extended&feeds=604&allowedtags=all&categories=all',
        'http://content.webgains.com/affiliates/datafeed.html?action=download&campaign=145659&username=shopelia&password=pichon69&format=xml&zipformat=gzip_notar&fields=extended&feeds=4529&allowedtags=all&categories=all',
        'http://content.webgains.com/affiliates/datafeed.html?action=download&campaign=145659&username=shopelia&password=pichon69&format=xml&zipformat=gzip_notar&fields=extended&feeds=3305&allowedtags=all&categories=all',
        'http://content.webgains.com/affiliates/datafeed.html?action=download&campaign=145659&username=shopelia&password=pichon69&format=xml&zipformat=gzip_notar&fields=extended&feeds=1423&allowedtags=all&categories=all',
        'http://content.webgains.com/affiliates/datafeed.html?action=download&campaign=145659&username=shopelia&password=pichon69&format=xml&zipformat=gzip_notar&fields=extended&feeds=4721&allowedtags=all&categories=all',
        'http://content.webgains.com/affiliates/datafeed.html?action=download&campaign=145659&username=shopelia&password=pichon69&format=xml&zipformat=gzip_notar&fields=extended&feeds=3501&allowedtags=all&categories=all',
        'http://content.webgains.com/affiliates/datafeed.html?action=download&campaign=145659&username=shopelia&password=pichon69&format=xml&zipformat=gzip_notar&fields=extended&feeds=1422&allowedtags=all&categories=all',
        'http://content.webgains.com/affiliates/datafeed.html?action=download&campaign=145659&username=shopelia&password=pichon69&format=xml&zipformat=gzip_notar&fields=extended&feeds=2655&allowedtags=all&categories=all',
        'http://content.webgains.com/affiliates/datafeed.html?action=download&campaign=145659&username=shopelia&password=pichon69&format=xml&zipformat=gzip_notar&fields=extended&feeds=3901&allowedtags=all&categories=all',
        'http://content.webgains.com/affiliates/datafeed.html?action=download&campaign=145659&username=shopelia&password=pichon69&format=xml&zipformat=gzip_notar&fields=extended&feeds=2753&allowedtags=all&categories=all',
        'http://content.webgains.com/affiliates/datafeed.html?action=download&campaign=145659&username=shopelia&password=pichon69&format=xml&zipformat=gzip_notar&fields=extended&feeds=4557&allowedtags=all&categories=all',
        'http://content.webgains.com/affiliates/datafeed.html?action=download&campaign=145659&username=shopelia&password=pichon69&format=xml&zipformat=gzip_notar&fields=extended&feeds=4261&allowedtags=all&categories=all',
        'http://content.webgains.com/affiliates/datafeed.html?action=download&campaign=145659&username=shopelia&password=pichon69&format=xml&zipformat=gzip_notar&fields=extended&feeds=4133&allowedtags=all&categories=all',
        'http://content.webgains.com/affiliates/datafeed.html?action=download&campaign=145659&username=shopelia&password=pichon69&format=xml&zipformat=gzip_notar&fields=extended&feeds=608&allowedtags=all&categories=all',
        'http://content.webgains.com/affiliates/datafeed.html?action=download&campaign=145659&username=shopelia&password=pichon69&format=xml&zipformat=gzip_notar&fields=extended&feeds=4217&allowedtags=all&categories=all',
        'http://content.webgains.com/affiliates/datafeed.html?action=download&campaign=145659&username=shopelia&password=pichon69&format=xml&zipformat=gzip_notar&fields=extended&feeds=748&allowedtags=all&categories=all',
        'http://content.webgains.com/affiliates/datafeed.html?action=download&campaign=145659&username=shopelia&password=pichon69&format=xml&zipformat=gzip_notar&fields=extended&feeds=2869&allowedtags=all&categories=all',
        'http://content.webgains.com/affiliates/datafeed.html?action=download&campaign=145659&username=shopelia&password=pichon69&format=xml&zipformat=gzip_notar&fields=extended&feeds=1568&allowedtags=all&categories=all',
        'http://content.webgains.com/affiliates/datafeed.html?action=download&campaign=145659&username=shopelia&password=pichon69&format=xml&zipformat=gzip_notar&fields=extended&feeds=1334&allowedtags=all&categories=all',
        'http://content.webgains.com/affiliates/datafeed.html?action=download&campaign=145659&username=shopelia&password=pichon69&format=xml&zipformat=gzip_notar&fields=extended&feeds=4481&allowedtags=all&categories=all',
        'http://content.webgains.com/affiliates/datafeed.html?action=download&campaign=145659&username=shopelia&password=pichon69&format=xml&zipformat=gzip_notar&fields=extended&feeds=330&allowedtags=all&categories=all',
        'http://content.webgains.com/affiliates/datafeed.html?action=download&campaign=145659&username=shopelia&password=pichon69&format=xml&zipformat=gzip_notar&fields=extended&feeds=3367&allowedtags=all&categories=all',
        'http://content.webgains.com/affiliates/datafeed.html?action=download&campaign=145659&username=shopelia&password=pichon69&format=xml&zipformat=gzip_notar&fields=extended&feeds=1553&allowedtags=all&categories=all',
        'http://content.webgains.com/affiliates/datafeed.html?action=download&campaign=145659&username=shopelia&password=pichon69&format=xml&zipformat=gzip_notar&fields=extended&feeds=4549&allowedtags=all&categories=all',
        'http://content.webgains.com/affiliates/datafeed.html?action=download&campaign=145659&username=shopelia&password=pichon69&format=xml&zipformat=gzip_notar&fields=extended&feeds=3465&allowedtags=all&categories=all'
              ]

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
        'description'     => 'description',
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

      self.category_fields = ['categories/category', 'merchant_category']

      params[:parser_class] = self.class
      self.filer = WebgainsFiler.new(params)
      self
    end

    def set_categories(product,record)
      super(product, record)
      product.each_pair do |k,v|
        record['_tags'] << "category:#{v}" if k =~ /\Acategories\/category/
      end

    end

    def process_product(product)
      record = super

      record['price'] = to_cents(record['price'])
      record['price_shipping'] = to_cents(record['price_shipping'])

      record
    end

  end
end

