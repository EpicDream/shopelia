require 'scrapers/reviews/amazon/amazon'
 
class ReviewsWorker
  include Sidekiq::Worker

  def perform merchant, product_id
    merchant = merchant.constantize
    Scrapers::Reviews::merchant::Scraper.scrape(product_id)
  end
end
