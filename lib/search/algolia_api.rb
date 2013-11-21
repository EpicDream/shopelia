module Search
  class AlgoliaApi

    def self.ean ean  
      algolia = Algolia::Index.new("products-feed-fr").search("", "tags" => "ean:#{ean}")
      if algolia["hits"].size > 0
        { name:algolia["hits"][0]["name"],
          brand:algolia["hits"][0]["brand"] || "",
          image_url:algolia["hits"][0]["image_url"],
          urls:algolia["hits"].map{|e| e["product_url"]} }
      else
        {}
      end
    rescue
      {}
    end
  end
end
