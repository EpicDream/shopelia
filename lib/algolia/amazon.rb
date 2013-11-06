# -*- encoding : utf-8 -*-

module AlgoliaFeed

  class AmazonFiler < FileUtils

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

      self.http_auth = params[:http_auth] || {:user => 'httpwwwprixin-21', :password => 'fjisnrsd48'}
    end
  end

  class Amazon < XmlParser

    # TODO: Missing categories for Amazon

    def initialize(params={})
      super

      self.product_field = params[:product_field] || 'item_data'

      self.conversions = {
        'item_ean'             => 'ean',
        'item_brand'           => 'brand',
        'item_name'            => 'name',
        'item_short_desc'      => 'description',
        'item_page_url'        => 'product_url',
        'item_price'           => 'price',
        'item_inventory'       => 'shipping_info',
        'item_shipping_charge' => 'price_shipping',
        'item_image_url'       => 'image_url',
        'item_salesrank'       => 'rank',
        'item_author'          => 'author'
      }

      self.category_fields = params[:category_fields] || ['item_category', 'merchant_cat_path']
      params[:parser_class] = self.class
      self.filer = AmazonFiler.new(params)
      self

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

      raise RejectedRecord.new("Item has no rank", :rejected_rank) unless record.has_key?('rank')
      raise RejectedRecord.new("Item rank is too low", :rejected_rank) if record['rank'] > 500_000
      raise RejectedRecord.new("Record has no usable image #{record['image_url']}", :rejected_img) unless (record.has_key?('image_url') and record['image_url'] =~ /\Ahttp/)
       record['price'] = to_cents(record['price'])
      record['price_shipping'] = '0' if record['price_shipping'] =~ /gratuite/i
      record['price_shipping'] = to_cents(record['price_shipping'])
      record['image_url'].gsub!(/\._.+?_\.jpg\Z/, '.jpg')
      record
    end
  end
end

