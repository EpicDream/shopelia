module Search
  class AmazonApi

    def self.ean ean 
      Amazon::Ecs.options = {
        :associate_tag => 'shopelia-21',
        :AWS_access_key_id => 'AKIAJMEFP2BFMHZ6VEUA',       
        :AWS_secret_key => '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'
      }
      res = Amazon::Ecs.item_lookup(ean, {
          :id_type        => 'EAN',
          :search_index   => 'All',
          :response_group => 'Large',
          :country        => 'fr',
      })
      item = res.items.first
      { name:CGI.unescapeHTML(item.get_element('ItemAttributes').get('Title')),
        image_url:item.get_element('LargeImage').get('URL'),
        urls:[ Linker.clean(item.get('DetailPageURL')) ]
      }
    rescue 
      {}
    end
  end
end