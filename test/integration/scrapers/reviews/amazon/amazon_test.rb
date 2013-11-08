require 'test__helper'
require 'scrapers/reviews/amazon/amazon'

class AmazonTest < ActiveSupport::TestCase
  URL = "http://www.amazon.fr/Game-Thrones-Le-Tr%C3%B4ne-Fer/dp/B00AAZ9F6K"
  
  setup do
    @product = Product.new(url:URL)
    @scraper = Scraper::Reviews::Amazon.new(@product)
  end
  
  test "reviews url page 1 and 2 from product url" do
    1.upto(2) do |page|
      expected_url = "http://www.amazon.fr/product-reviews/B00AAZ9F6K/?pageNumber=#{page}&showViewpoints=0&sortBy=byRankDescending"
      assert_equal expected_url, @scraper.reviews_url(page), "reviews url fails for page #{page}"
    end
  end
  
  test "get first page of reviews of a given asin" do
    
  end
  
end