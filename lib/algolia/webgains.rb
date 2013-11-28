# -*- encoding : utf-8 -*-

module AlgoliaFeed

  class WebgainsFiler < Filer

    def initialize(params={})
      super

      self.urls = params[:urls] || [
        'http://content.webgains.com/affiliates/datafeed.html?action=download&campaign=145659&username=shopelia&password=pichon69&format=xml&zipformat=gzip_notar&fields=extended&programs=all&allowedtags=all&categories=all'
      ]

      self.clean_xml = false

      self.parser_class = params[:parser_class] || 'AlgoliaFeed::Webgains'
    end

    def decompress_datafile(raw_file, dir=nil, decoded_file=nil)
      path = super
      contents = File.read(path)
      contents.gsub!(/\uFFFE/, '') # Remove broken UTF8
      File.open(path, 'wb') do |f|
        f.puts contents
      end
      xmllint(path)
      path
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

