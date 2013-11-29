# -*- encoding : utf-8 -*-

module AlgoliaFeed

  class EffiliationFiler < Filer

    def initialize(params={})
      super
      self.urls = params[:urls] || [
        'http://feeds.effiliation.com/myformat/12949305',
        'http://feeds.effiliation.com/myformat/12949306',
        'http://feeds.effiliation.com/myformat/12949308',
        'http://feeds.effiliation.com/myformat/12949309',
        'http://feeds.effiliation.com/myformat/12949310',
        'http://feeds.effiliation.com/myformat/12949307',
        'http://feeds.effiliation.com/myformat/12949311',
        'http://feeds.effiliation.com/myformat/12949312',
        'http://feeds.effiliation.com/myformat/12949313',
        'http://feeds.effiliation.com/myformat/12949314',
        'http://feeds.effiliation.com/myformat/12949315',
        'http://feeds.effiliation.com/myformat/12949316',
        'http://feeds.effiliation.com/myformat/12949317',
        'http://feeds.effiliation.com/myformat/12949318',
        'http://feeds.effiliation.com/myformat/12949319',
        'http://feeds.effiliation.com/myformat/12949322',
        'http://feeds.effiliation.com/myformat/12949323',
        'http://feeds.effiliation.com/myformat/12949324',
        'http://feeds.effiliation.com/myformat/12949325',
        'http://feeds.effiliation.com/myformat/12949326',
        'http://feeds.effiliation.com/myformat/12949327',
        'http://feeds.effiliation.com/myformat/12949328',
        'http://feeds.effiliation.com/myformat/12949329',
        'http://feeds.effiliation.com/myformat/12949330',
        'http://feeds.effiliation.com/myformat/12949331',
        'http://feeds.effiliation.com/myformat/12949332',
        'http://feeds.effiliation.com/myformat/12949333',
        'http://feeds.effiliation.com/myformat/12949334',
        'http://feeds.effiliation.com/myformat/12949335',
        'http://feeds.effiliation.com/myformat/12949336',
        'http://feeds.effiliation.com/myformat/12949337',
        'http://feeds.effiliation.com/myformat/12949338',
        'http://feeds.effiliation.com/myformat/12949339',
        'http://feeds.effiliation.com/myformat/12949340',
        'http://feeds.effiliation.com/myformat/12949341',
        'http://feeds.effiliation.com/myformat/12949342',
        'http://feeds.effiliation.com/myformat/12949343',
        'http://feeds.effiliation.com/myformat/12949344',
        'http://feeds.effiliation.com/myformat/12949345',
        'http://feeds.effiliation.com/myformat/12949346',
        'http://feeds.effiliation.com/myformat/12949347',
        'http://feeds.effiliation.com/myformat/12949348',
        'http://feeds.effiliation.com/myformat/12949349',
        'http://feeds.effiliation.com/myformat/12949350',
        'http://feeds.effiliation.com/myformat/12949351',
        'http://feeds.effiliation.com/myformat/12949352',
        'http://feeds.effiliation.com/myformat/12949353',
        'http://feeds.effiliation.com/myformat/12949354',
        'http://feeds.effiliation.com/myformat/12949355',
        'http://feeds.effiliation.com/myformat/12949356',
        'http://feeds.effiliation.com/myformat/12949357',
        'http://feeds.effiliation.com/myformat/12949358',
        'http://feeds.effiliation.com/myformat/12949359',
        'http://feeds.effiliation.com/myformat/12949360',
        'http://feeds.effiliation.com/myformat/12949361',
        'http://feeds.effiliation.com/myformat/12949362',
        'http://feeds.effiliation.com/myformat/12949363',
        'http://feeds.effiliation.com/myformat/12949364',
        'http://feeds.effiliation.com/myformat/12949365',
        'http://feeds.effiliation.com/myformat/12949366',
        'http://feeds.effiliation.com/myformat/12949367',
        'http://feeds.effiliation.com/myformat/12949368',
        'http://feeds.effiliation.com/myformat/12949369',
        'http://feeds.effiliation.com/myformat/12949370',
        'http://feeds.effiliation.com/myformat/12949371',
        'http://feeds.effiliation.com/myformat/12949372',
        'http://feeds.effiliation.com/myformat/12949373',
        'http://feeds.effiliation.com/myformat/12949374',
        'http://feeds.effiliation.com/myformat/12949375',
        'http://feeds.effiliation.com/myformat/12949376',
        'http://feeds.effiliation.com/myformat/12949377',
        'http://feeds.effiliation.com/myformat/12949378',
        'http://feeds.effiliation.com/myformat/12949379',
        'http://feeds.effiliation.com/myformat/12949380',
        'http://feeds.effiliation.com/myformat/12949381',
        'http://feeds.effiliation.com/myformat/12949382',
        'http://feeds.effiliation.com/myformat/12949383',
        'http://feeds.effiliation.com/myformat/12949384',
        'http://feeds.effiliation.com/myformat/12949385',
        'http://feeds.effiliation.com/myformat/12949386',
        'http://feeds.effiliation.com/myformat/12949387',
        'http://feeds.effiliation.com/myformat/12949388',
        'http://feeds.effiliation.com/myformat/12949389',
        'http://feeds.effiliation.com/myformat/12949390',
        'http://feeds.effiliation.com/myformat/12949391',
        'http://feeds.effiliation.com/myformat/12949392',
        'http://feeds.effiliation.com/myformat/12949393',
        'http://feeds.effiliation.com/myformat/12949394',
        'http://feeds.effiliation.com/myformat/12949395',
        'http://feeds.effiliation.com/myformat/12949396',
        'http://feeds.effiliation.com/myformat/12949397',
        'http://feeds.effiliation.com/myformat/12949398',
        'http://feeds.effiliation.com/myformat/12949399',
        'http://feeds.effiliation.com/myformat/12949400',
        'http://feeds.effiliation.com/myformat/12949401',
        'http://feeds.effiliation.com/myformat/12949402',
        'http://feeds.effiliation.com/myformat/12949403',
        'http://feeds.effiliation.com/myformat/12949404',
        'http://feeds.effiliation.com/myformat/12949405'
      ]

      self.parser_class = params[:parser_class] || 'AlgoliaFeed::Effiliation'

    end
  end

  class Effiliation < XmlParser

    def initialize(params={})
      super

      self.product_field = params[:product_field] || 'produit'

      self.conversions = params[:conversions] || {
        'name       '   => 'name',
        'url_product'   => 'product_url',
        'url_image'     => 'image_url',
        'description'   => 'description',
        'price'         => 'price',
        'currency'      => 'currency',
        'availability'  => 'availability',
        'shipping_cost' => 'price_shipping',
        'delivery_time' => 'shipping_info',
        'ean'           => 'ean',
        'brand'         => 'brand',
      }

      self.category_fields = params[:category_fields] || ['merchant_univers_name', 'merchant_category_name', 'merchant_department_name', 'merchant_store_name' ]
      params[:parser_class] = self.class
      self.filer = EffiliationFiler.new(params)
      self
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

      record['price'] = to_cents(record['price'])
      record['price_shipping'] = to_cents(record['price_shipping'])

      record.delete('rank') if record['rank'] == 0

      record
    end
  end
end

