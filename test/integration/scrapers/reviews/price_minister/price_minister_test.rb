# -*- encoding : utf-8 -*-
require 'test__helper'
require 'scrapers/reviews/price_minister/price_minister'

class Scrapers::Reviews::PriceMinisterTest < ActiveSupport::TestCase
  fixtures :products
  fixtures :product_reviews
  
  URL = "http://www.priceminister.com/offer/buy/180624024/grand-theft-auto-v.html"
  
  setup do
    @product = products(:grand_theft_auto)
    @scraper = Scrapers::Reviews::PriceMinister::Scraper.new(@product)
  end
  
  test "reviews url page 1 and 2 from product url, with sort by date desc" do
    1.upto(2) do |page|
      expected_form_data = {start:(page -1)*10, max:10, sort:'FO_MODIFICATION_DATE_DESC'}
      expected_url = "http://www.priceminister.com/review?action=list&productid=180624024"
      reviews_url = @scraper.reviews_url(page)
      
      assert_equal expected_form_data, reviews_url[:form_data]
      assert_equal expected_url, reviews_url[:url]
    end
  end
  
  test "get first page of reviews for a given product_id" do
    reviews = @scraper.reviews_of_page(1)
    review = reviews.first
    
    assert_equal 10, reviews.count
    assert review.author =~ /[A-Za-z\d]*/
    assert_equal 5, review.rating
    assert Date.parse("2013-11-12") <= review.date
    assert review.content.length > 2
  end
  
  test "reviews of first page as hashes" do
    reviews = @scraper.reviews_of_page(1)
    reviews.each do |review|
      review = review.to_hash
      assert review[:rating].between?(0, 5)
      assert review[:author].length > 3
      assert review[:content].length > 2
      assert_equal @product.id, review[:product_id]
    end
  end
  
  test "synchronize all reviews of this product" do
    skip
    @product = products(:grand_theft_auto)
    
    Scrapers::Reviews::PriceMinister::Scraper.scrape(@product.id)
    assert_equal 100, @product.product_reviews.count
  end
  
  test "create incident" do
    Scrapers::Reviews::Synchronizer.stubs(:synchronize).raises
    Scrapers::Reviews::PriceMinister::Scraper::PAGES = (1..1)
    @product = products(:grand_theft_auto)
    
    Scrapers::Reviews::PriceMinister::Scraper.scrape(@product.id)
    
    incidents = Incident.all
    incident = incidents.first
    expected_description = "url : http://www.priceminister.com/review?action=list&productid=180624024" 
  
    assert_equal 10, Incident.count
    assert_equal expected_description, incident.description
  end
  
  test "if first review exists in database stop scraping" do
    product = products(:grand_theft_auto)
    review = product_reviews(:grand_theft_auto)
    
    scraper = Scrapers::Reviews::PriceMinister::Scraper.new(product)
    scraper.stubs(:reviews_of_page).with(1).returns([review_stub(review.author, product)])
    scraper.stubs(:reviews_of_page).with(2).returns([])
    
    Scrapers::Reviews::Synchronizer.expects(:synchronize).never
    
    scraper.run
  end
  
  private
  
  def review_stub author, product
    review = Scrapers::Reviews::PriceMinister::Review.new(nil)
    hash_review = {rating:1, author:author, content:"", published_at:Time.now, product_id:product.id}
    review.stubs(:to_hash).returns(hash_review)
    review.stubs(:author).returns(author)
    review
  end
end
