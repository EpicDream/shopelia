# -*- encoding : utf-8 -*-

module AlgoliaFeed

  class Zanox < AlgoliaFeed

    def initialize(params={})
      super

      self.urls = params[:urls] || [
        "http://productdata.zanox.com/exportservice/v1/rest/22189354C1364358154.xml?ticket=88FC91472561713FA4B6A466542E9240AF65935CD5963D40B2C8FAA44F0CC042&gZipCompress=yes",
        "http://productdata.zanox.com/exportservice/v1/rest/19436028C1562252816.xml?ticket=88FC91472561713FA4B6A466542E9240AF65935CD5963D40B2C8FAA44F0CC042&gZipCompress=yes",
        "http://productdata.zanox.com/exportservice/v1/rest/18920697C1372641144.xml?ticket=88FC91472561713FA4B6A466542E9240AF65935CD5963D40B2C8FAA44F0CC042&gZipCompress=yes",
        "http://productdata.zanox.com/exportservice/v1/rest/19054231C2048768278.xml?ticket=F03A5E4E67A27FD5925A570370AD7885&gZipCompress=yes",
        "http://productdata.zanox.com/exportservice/v1/rest/19089773C1754659089.xml?ticket=88FC91472561713FA4B6A466542E9240AF65935CD5963D40B2C8FAA44F0CC042&gZipCompress=yes",
        "http://productdata.zanox.com/exportservice/v1/rest/19472705C2093117078.xml?ticket=88FC91472561713FA4B6A466542E9240AF65935CD5963D40B2C8FAA44F0CC042&gZipCompress=yes",
        "http://productdata.zanox.com/exportservice/v1/rest/19436175C242487251.xml?ticket=F03A5E4E67A27FD5925A570370AD7885&gZipCompress=yes",
        "http://productdata.zanox.com/exportservice/v1/rest/19024603C1357169475.xml?ticket=F03A5E4E67A27FD5925A570370AD7885&gZipCompress=yes"
      ]

      self.conversions = {
        'name'                 => 'name',
        'manufacturer'         => 'brand',
        'ean'                  => 'ean',
        'price'                => 'price',
        'shippingHandlingCost' => 'shipping_price',
        'deliveryTime'         => 'shipping_info',
        'currencyCode'         => 'currency',
        'deepLink'             => 'product_url',
        'number'               => 'reference',
        'logDescription'       => 'description'
      }

#      self.index_name = 'zanox'

    end

    def canonize_url(url)
      matches = /eurl=(.+?html)/.match(url)
      return URI.unescape(matches[1]) if matches.present?
      
      matches = /\[\[(.+?\.fnac.com.+?)\]\]/.match(url)
      return "http://#{matches[1]}" if matches.present?

      matches = /\[\[(.+?\.darty.com.+?)\]\]/.match(url)
      return matches[1] if matches.present?

      matches = /\[\[(.+?\.toysrus.fr.+?)\]\]/.match(url)
      return matches[1] if matches.present?

      matches = /\[\[(.+?\.imenager.com.+?)\]\]/.match(url)
      return matches[1] if matches.present?

      matches = /\[\[(.+?\.eveiletjeux.+?)\]\]/.match(url)
      return matches[1] if matches.present?

      url
    end

    def best_image(product)
      return product['largeImage']  if product.has_key?('largeImage')
			return product['mediumImage'] if product.has_key?('mediumImage')
			return product['smallImage']  if product.has_key?('smallImage')
		  return
    end

    def merchant_tag(url)
      return 'merchant_name:Carrefour'     if url =~ /carrefour\.fr/
      return 'merchant_name:Darty'         if url =~ /darty\.fr/
      return "merchant_name:Toys 'R' Us"   if url =~ /toysrus\.fr/
      return 'merchant_name:Fnac'          if url =~ /fnac\.com/
      return 'merchant_name:Imenager'      if url =~ /imenager\.fr/
      return 'merchant_name:Conforama'     if url =~ /conforama\.fr/
      return 'merchant_name:RueduCommerce' if url =~ /rueducommerce\.fr/
      return 'merchant_name:EveiletJeux'   if url =~ /eveiletjeux\.com/
      return 'merchant_name:Zanox'
    end
      
    def process_product(product)
      record = super

      record['price'] = (record['price'].to_f * 100).to_i.to_s
      record['shipping_price'] = (record['shipping_price'].to_f * 100).to_i.to_s

      img = best_image(product)
      record['image_url'] = img if img.present?

      categories = get_categories([product['merchantCategory']])
      categories.each do |c|
        record['_tags'] << "category:#{c.to_s}"
      end
      record['category'] = categories.join(' > ')
      record
    end
  end
end

