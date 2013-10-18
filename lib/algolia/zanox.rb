# -*- encoding : utf-8 -*-

module AlgoliaFeed

  class Zanox < AlgoliaFeed

    def initialize
      super

      self.urls = [
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

#      self.algolia_index_name = 'zanox'

    end

    def canonize_url(url)
      matches = /eurl=(.+?html)/.match(url)
      if matches.present?
        return URI.unescape(matches[1])
      end
      matches = /\[\[(.+?\.fnac.com.+?)\]\]/.match(url)
      if matches.present?
        return "http://#{matches[1]}"
      end
      matches = /\[\[(.+?\.darty.com.+?)\]\]/.match(url)
      if matches.present?
        return matches[1]
      end
      matches = /\[\[(.+?\.toysrus.fr.+?)\]\]/.match(url)
      if matches.present?
        return matches[1]
      end
      matches = /\[\[(.+?\.imenager.com.+?)\]\]/.match(url)
      if matches.present?
        return matches[1]
      end
      matches = /\[\[(.+?\.eveiletjeux.+?)\]\]/.match(url)
      if matches.present?
        return matches[1]
      end
      url
    end

    def best_image(product)
      if product.search('largeImage').text.size > 0
        return product.search('largeImage').text
      elsif product.search('mediumImage').text.size > 0
        return product.search('mediumImage').text
      elsif product.search('smallImage').text.size > 0
        return product.search('smallImage').text
      end
    end

    def merchant_tag(url)
      if url =~ /carrefour\.fr/
        return 'merchant_name:Carrefour'
      elsif url =~ /darty\.fr/
        return 'merchant_name:Darty'
      elsif url =~ /toysrus\.fr/
        return 'merchant_name:ToysRus'
      elsif url =~ /fnac\.com/
        return 'merchant_name:Fnac'
      elsif url =~ /imenager\.fr/
        return 'merchant_name:Imenager'
      elsif url =~ /conforama\.fr/
        return 'merchant_name:Conforama'
      elsif url =~ /rueducommerce\.fr/
        return 'merchant_name:RueduCommerce'
      elsif url =~ /eveiletjeux\.com/
        return 'merchant_name:EveiletJeux'
      else
        return 'merchant_name:Zanox'
      end
    end
      
    def process_product(product)
      record = super

      record['product_url'] = canonize_url(record['product_url'])
      record['price'] = (record['price'].to_f * 100).to_i.to_s
      record['shipping_price'] = (record['shipping_price'].to_f * 100).to_i.to_s

      img = best_image(product)
      record['image_url'] = img if img.present?

      record['_tags'] = [] unless record.has_key?('_tags')

      categories = []
      if product.search('merchantCategory').text.size > 0
        cats = product.search('merchantCategory').text.split(/\s+\-\s+/)
        categories << cats
      end
      categories.flatten.each do |c|
        record['_tags'] << "category:#{c.to_s}"
      end
      record['category'] = categories.join('>')

      record['_tags'] << merchant_tag(record['product_url'])
      record
    end
  end
end

