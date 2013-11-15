require 'scrapers/reviews/scrapers'

class ReviewsWorker
  include Sidekiq::Worker

  def perform hash
    product = Product.find hash["product_id"]
    Scrapers::Reviews.scrape(product)
  end
end
