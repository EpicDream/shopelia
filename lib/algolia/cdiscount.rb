# -*- encoding : utf-8 -*-

module AlgoliaFeed

  class Cdiscount < AlgoliaFeed

    def initialize
      super

      self.urls = ['http://pf.tradedoubler.com/export/export?myFeed=13692964912238732&myFormat=13692964912238732']

      self.conversions = {
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

    end

    def canonize_url(url)
      matches = /url\((.+?)\)/.match(url)
      return url unless matches[1].present?
      new_url = URI.unescape(matches[1])
      new_url.gsub!(/\&refer.+/, '')
      new_url
    end
      
    def process_product(product)
      record = super
      record['_tags'] = [] unless record.has_key?('_tags')
      categories = []
      categories << product.xpath('TDCategoryName').text if product.xpath('TDCategoryName').text.size > 0
      categories << product.xpath('merchantCategoryName').text if product.xpath('merchantCategoryName').text.size > 0
      categories.each do |c|
        records['_tags'] << "category:#{c}"
      end
      record['category'] = categories.join('>')
      record['_tags'] << "merchant_name:Cdiscount"
      record['price'] = (record['price'].to_f * 100).to_i.to_s
      record['shipping_price'] = (record['shipping_price'].to_f * 100).to_i.to_s
      record['product_url'] = canonize_url(record['product_url'])
      record
    end
  end
end

