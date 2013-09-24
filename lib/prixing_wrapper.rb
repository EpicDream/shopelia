class PrixingWrapper

  def self.convert data
    product = data[0]["product"]
    
    image_url = nil
    best_score = 0
    (product["images_urls"] || []).each do |e|
      if e["score"] > best_score
        image_url = e["large"]
        best_score = e["score"]
      end
    end

    urls = (data[2]["prices_online"] + data[6]["prices_amazon"]).map { |e| e["url"] }

    { name:product["title"],
      image_url:image_url,
      urls:urls }
  end
end