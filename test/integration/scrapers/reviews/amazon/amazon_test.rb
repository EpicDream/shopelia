# -*- encoding : utf-8 -*-
require 'test__helper'
require 'scrapers/reviews/amazon/amazon'

class AmazonTest < ActiveSupport::TestCase
  fixtures :products
  
  URL = "http://www.amazon.fr/Game-Thrones-Le-Tr%C3%B4ne-Fer/dp/B00AAZ9F6K"
  
  setup do
    @product = Product.new(url:URL)
    @product.id = 1
    @scraper = Scrapers::Reviews::Amazon::Scraper.new(@product)
  end
  
  test "reviews url page 1 and 2 from product url, with bySubmissionDateDescending sort" do
    1.upto(2) do |page|
      expected_url = "http://www.amazon.fr/product-reviews/B00AAZ9F6K/?pageNumber=#{page}&showViewpoints=0&sortBy=bySubmissionDateDescending"
      assert_equal expected_url, @scraper.reviews_url(page), "reviews url fails for page #{page}"
    end
  end
  
  test "get first page of reviews of a given asin" do
    reviews = @scraper.reviews_of_page(1)
    review = reviews.first
    expected_content = "Un vrai plaisir de pouvoir enfin regarder cette superbe série est blu-ray.Une de mes séries favorites, une image de très bonne qualité, la bande-son, en anglais comme en français, est impeccable.Et la série, que dire, regardez-la, on ne peut plus s'arrêter quand on a commencé ;)"

    assert_equal 10, reviews.count
    assert_equal 'A1NKS428YJSR4K', review.author
    assert_equal 5, review.rating
    assert_equal Date.parse("5 novembre 2013"), review.date
    assert_equal expected_content, review.content
  end
  
  test "reviews of first page as hashes" do
    reviews = @scraper.reviews_of_page(1)
    reviews.each do |review|
      review = review.to_hash
      assert review[:rating].between?(0, 5)
      assert review[:author].length > 10
      assert review[:content].length > 2
      assert_equal 1, review[:product_id]
    end
  end
  
  test "synchronize all reviews of this product" do
    skip
    @product = products(:game_of_throne)
    
    Scrapers::Reviews::Amazon::Scraper.scrape(@product.id)
    
    assert_equal 100, @product.product_reviews.count
  end
  
  test "create incident" do
    Scrapers::Reviews::Synchronizer.stubs(:synchronize).raises
    Scrapers::Reviews::Amazon::Scraper::PAGES = (1..1)
    @product = products(:game_of_throne)
    
    Scrapers::Reviews::Amazon::Scraper.scrape(@product.id)
    
    incidents = Incident.all
    incident = incidents.first
    expected_description = "url : http://www.amazon.fr/product-reviews/B00AAZ9F6K/?pageNumber=1&showViewpoints=0&sortBy=bySubmissionDateDescending" 
  
    assert_equal 10, Incident.count
    assert_equal expected_description, incident.description
  end
  
end
