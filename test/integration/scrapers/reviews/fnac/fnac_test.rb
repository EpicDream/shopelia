# -*- encoding : utf-8 -*-
require 'test__helper'
require 'scrapers/reviews/fnac/fnac'

class Scrapers::Reviews::FnacTest < ActiveSupport::TestCase
  fixtures :products
  fixtures :product_reviews
  
  
  setup do
    @product = products(:enceintes_ihome)
    @scraper = Scrapers::Reviews::Fnac::Scraper.new(@product)
  end
  
  test "get first page of reviews for a given product_id" do
    reviews = @scraper.reviews_of_page(1)
    review = reviews[1]

    assert_equal 4, reviews.count
    assert review.author =~ /[A-Za-z\d]*/
    assert_equal 2, review.rating
    assert Date.parse("2012-09-13") <= review.date
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
    Scrapers::Reviews::Fnac::Scraper.scrape(@product.id)
    assert_equal 4, @product.product_reviews.count
  end
  
  test "create incident" do
    Scrapers::Reviews::Synchronizer.stubs(:synchronize).raises
    Scrapers::Reviews::Fnac::Scraper::PAGES = (1..1)
    
    Scrapers::Reviews::Fnac::Scraper.scrape(@product.id)
    
    incidents = Incident.all
    incident = incidents.first
    expected_description = "url : http://www.fnac.com/iHome-iA17/a3488733/w-4, index : 1"
  
    assert_equal 4, Incident.count
    assert_equal expected_description, incident.description
  end
  
end
