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
      # self.index_name = params[:index_name] || 'cdiscount'
    end

    def canonize_url(url)
      matches = /url\((.+?)\)/.match(url)
      return url unless matches.present?
      new_url = URI.unescape(matches[1])
      new_url.gsub!(/\&refer.+/, '')
      new_url
    end
      
    def process_product(product)
      record = super
      categories = get_categories([product['TDCategoryName'],  product['merchantCategoryName']])
      categories.each do |c|
        record['_tags'] << "category:#{c.to_s}"
      end
      record['category'] = categories.join('>')
      record['price'] = (record['price'].to_f * 100).to_i.to_s
      record['shipping_price'] = (record['shipping_price'].to_f * 100).to_i.to_s
      record['product_url'] = canonize_url(record['product_url'])
      record
    end
  end
end

