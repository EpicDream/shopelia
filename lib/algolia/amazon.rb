# -*- encoding : utf-8 -*-

module AlgoliaFeed

  class Amazon < AlgoliaFeed

    def initialize(params={})
      super

      self.urls = params[:urls] || [
        'https://assoc-datafeeds-eu.amazon.com/datafeed/getFeed?filename=fr_amazon_apparel.xml.gz',
        'https://assoc-datafeeds-eu.amazon.com/datafeed/getFeed?filename=fr_amazon_baby.xml.gz',
        'https://assoc-datafeeds-eu.amazon.com/datafeed/getFeed?filename=fr_amazon_books.xml.gz',
        'https://assoc-datafeeds-eu.amazon.com/datafeed/getFeed?filename=fr_amazon_ce.xml.gz',
        'https://assoc-datafeeds-eu.amazon.com/datafeed/getFeed?filename=fr_amazon_dvd.xml.gz',
        'https://assoc-datafeeds-eu.amazon.com/datafeed/getFeed?filename=fr_amazon_electronics.xml.gz',
        'https://assoc-datafeeds-eu.amazon.com/datafeed/getFeed?filename=fr_amazon_gz_auto.xml.gz',
        'https://assoc-datafeeds-eu.amazon.com/datafeed/getFeed?filename=fr_amazon_gz_hi.xml.gz',
        'https://assoc-datafeeds-eu.amazon.com/datafeed/getFeed?filename=fr_amazon_gz_large_appliancies.xml.gz',
        'https://assoc-datafeeds-eu.amazon.com/datafeed/getFeed?filename=fr_amazon_hpc.xml.gz',
        'https://assoc-datafeeds-eu.amazon.com/datafeed/getFeed?filename=fr_amazon_javari.xml.gz',
        'https://assoc-datafeeds-eu.amazon.com/datafeed/getFeed?filename=fr_amazon_kitchen.xml.gz',
        'https://assoc-datafeeds-eu.amazon.com/datafeed/getFeed?filename=fr_amazon_music.xml.gz',
        'https://assoc-datafeeds-eu.amazon.com/datafeed/getFeed?filename=fr_amazon_office.xml.gz',
        'https://assoc-datafeeds-eu.amazon.com/datafeed/getFeed?filename=fr_amazon_pc.xml.gz',
        'https://assoc-datafeeds-eu.amazon.com/datafeed/getFeed?filename=fr_amazon_shoes.xml.gz',
        'https://assoc-datafeeds-eu.amazon.com/datafeed/getFeed?filename=fr_amazon_software.xml.gz',
        'https://assoc-datafeeds-eu.amazon.com/datafeed/getFeed?filename=fr_amazon_sports.xml.gz',
        'https://assoc-datafeeds-eu.amazon.com/datafeed/getFeed?filename=fr_amazon_toys.xml.gz',
        'https://assoc-datafeeds-eu.amazon.com/datafeed/getFeed?filename=fr_amazon_videogames.xml.gz',
        'https://assoc-datafeeds-eu.amazon.com/datafeed/getFeed?filename=fr_amazon_watches.xml.gz'
      ]

      self.product_field = params[:product_field] || 'item_data'

      self.conversions = {
        'item_ean'             => 'ean',
        'item_brand'           => 'brand',
        'item_name'            => 'name',
        'item_short_desc'      => 'description',
        'item_page_url'        => 'product_url',
        'item_price'           => 'price',
        'item_inventory'       => 'shipping_info',
        'item_shipping_charge' => 'shipping_price',
        'item_image_url'       => 'image_url',
        'item_salesrank'       => 'rank'
      }

      self.category_fields = params[:category_fields] || ['item_category', 'merchant_cat_path']

      self.http_auth = params[:http_auth] || {:user => 'httpwwwprixin-21', :password => 'fjisnrsd48'}

    end

    def canonize(url)
      if m = url.match(/\/dp\/([A-Z0-9]+)/)
        return "http://www.amazon.fr/dp/#{m[1]}"
      elsif m = url.match(/\/gp\/product\/([A-Z0-9]+)/)
        return "http://www.amazon.fr/gp/product/#{m[1]}"
      else
        return Linker.clean(url)
      end
    end

    def product_hash(xml)
      super(Nokogiri::XML(xml).xpath('//item_data/item_basic_data').to_s)
    end

    def process_product(product)
      record = super

      record['price'] = to_cents(record['price'])
      record['shipping_price'] = '0' if record['shipping_price'] =~ /gratuite/i
      record['shipping_price'] = to_cents(record['shipping_price'])

      record
    end
  end
end

