# -*- encoding : utf-8 -*-

require 'test__helper'
require 'scrapers/reviews/synchronizer'

class Scrapers::Reviews::SynchronizerTest < ActiveSupport::TestCase
  fixtures :products
  
  setup do
    @synchronizer = Scrapers::Reviews::Synchronizer
    @product = products(:usbkey)
    @review = {rating:4, author:"AZ199191", published_at:Date.parse("1 octobre 2013"), content:"Super!", product_id:@product.id}
  end
  
  test "synchronize review" do
    @synchronizer.synchronize(@review)
    review = @product.product_reviews.first
    
    @review.each { |key, value| assert_equal value, review.send(key) }
  end
  
  test "only one review per author" do
    assert_difference('ProductReview.count', 1) do
      3.times { @synchronizer.synchronize(@review)}
    end
  end
  
end
