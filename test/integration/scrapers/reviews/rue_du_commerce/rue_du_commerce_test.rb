# -*- encoding : utf-8 -*-
require 'test__helper'
require 'scrapers/reviews/rue_du_commerce/rue_du_commerce'

class Scrapers::Reviews::RueDuCommerceTest < ActiveSupport::TestCase
  fixtures :products
  fixtures :product_reviews
  
  setup do
    @product = products(:patisserie)
    @scraper = Scrapers::Reviews::RueDuCommerce::Scraper.new(@product)
  end
  
  test "get first page of reviews for a given product_id" do
    reviews = @scraper.reviews_of_page(1)
    review = reviews.first
    assert_equal 1, reviews.count
    assert review.author =~ /[A-Za-z\d]*/
    assert_equal 5, review.rating
    assert Date.parse("2009-10-08") <= review.date
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
    Scrapers::Reviews::RueDuCommerce::Scraper.scrape(@product.id)
    assert_equal 1, @product.product_reviews.count
  end
  
  test "create incident" do
    Incident.destroy_all
    Scrapers::Reviews::Synchronizer.stubs(:synchronize).raises
    Scrapers::Reviews::RueDuCommerce::Scraper::PAGES = (1..1)
    Scrapers::Reviews::RueDuCommerce::Scraper.scrape(@product.id)
    
    incidents = Incident.all
    incident = incidents.last
    expected_description = "url : http://www.rueducommerce.fr/m/ps/mpid:MP-BB9E6M4827947#!moid:MO-BB9E6M7393322, index : 1"
  
    assert_equal 1, Incident.count
    assert_equal expected_description, incident.description
  end
  
end
