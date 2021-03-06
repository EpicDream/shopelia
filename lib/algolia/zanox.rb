# -*- encoding : utf-8 -*-

module AlgoliaFeed

  class ZanoxFiler < Filer

    def initialize(params={})
      super

      self.urls = params[:urls] || [
        "http://productdata.zanox.com/exportservice/v1/rest/22189354C1364358154.xml?ticket=88FC91472561713FA4B6A466542E9240AF65935CD5963D40B2C8FAA44F0CC042&gZipCompress=yes", # carrefour.fr
        "http://productdata.zanox.com/exportservice/v1/rest/19436028C1562252816.xml?ticket=88FC91472561713FA4B6A466542E9240AF65935CD5963D40B2C8FAA44F0CC042&gZipCompress=yes", # darty.com
        "http://productdata.zanox.com/exportservice/v1/rest/18920697C1372641144.xml?ticket=88FC91472561713FA4B6A466542E9240AF65935CD5963D40B2C8FAA44F0CC042&gZipCompress=yes", # toysrus.fr
        "http://productdata.zanox.com/exportservice/v1/rest/19054231C2048768278.xml?ticket=F03A5E4E67A27FD5925A570370AD7885&gZipCompress=yes", # fnac.com
        "http://productdata.zanox.com/exportservice/v1/rest/19089773C1754659089.xml?ticket=88FC91472561713FA4B6A466542E9240AF65935CD5963D40B2C8FAA44F0CC042&gZipCompress=yes", # imenager
        "http://productdata.zanox.com/exportservice/v1/rest/19472705C2093117078.xml?ticket=88FC91472561713FA4B6A466542E9240AF65935CD5963D40B2C8FAA44F0CC042&gZipCompress=yes", # Conforama
        "http://productdata.zanox.com/exportservice/v1/rest/19436175C242487251.xml?ticket=F03A5E4E67A27FD5925A570370AD7885&gZipCompress=yes", # rueducommerce.fr
        "http://productdata.zanox.com/exportservice/v1/rest/19024603C1357169475.xml?ticket=F03A5E4E67A27FD5925A570370AD7885&gZipCompress=yes" # eveiletjeux.com
      ]

      self.parser_class = params[:parser_class] || 'AlgoliaFeed::Zanox'

    end
  end

  class Zanox < XmlParser

    def initialize(params={})
      super

      self.conversions = {
        'name'                 => 'name',
        'manufacturer'         => 'brand',
        'ean'                  => 'ean',
        'price'                => 'price',
        'shippingHandlingCost' => 'price_shipping',
        'deliveryTime'         => 'shipping_info',
        'currencyCode'         => 'currency',
        'deepLink'             => 'product_url',
        'number'               => 'reference',
        'logDescription'       => 'description'
      }

      self.category_fields = ['merchantCategory']
      params[:parser_class] = self.class
      self.filer = ZanoxFiler.new(params)
      self
    end

    def best_image(product)
      return product['largeImage']  if product.has_key?('largeImage')
      return product['mediumImage'] if product.has_key?('mediumImage')
      return product['smallImage']  if product.has_key?('smallImage')
      raise RejectedRecord.new("Record has no images", :rejected_img)
    end

    def process_product(product)
      record = super

      record['price'] = to_cents(record['price'])
      record['price_shipping'] = to_cents(record['price_shipping'])

      record['image_url'] = best_image(product)
      record['_tags'] = record['_tags'].grep(/\A[^ean:]/) if record['merchant_name'] == 'Conforama'

      record
    end
  end
end

