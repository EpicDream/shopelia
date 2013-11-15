require 'scrapers/reviews/amazon/amazon'
 
class ReviewsWorker
  include Sidekiq::Worker

  def perform hash
    product = Product.find(hash["product_id"])
    if product.merchant.domain == "amazon.fr"
      Scrapers::Reviews::Amazon::Scraper.scrape(product.id)
    end
  end
end
