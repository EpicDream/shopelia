module Search
  class Ean

    def self.get ean
      amazon = Search::AmazonApi.ean(ean)
      algolia = Search::AlgoliaApi.ean(ean)
      { name:amazon[:name] || algolia[:name],
        image_url:amazon[:image_url] || algolia[:image_url],
        urls:((amazon[:urls] || []) + (algolia[:urls] || [])).uniq }
    end
  end
end