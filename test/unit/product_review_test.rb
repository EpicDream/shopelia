require 'test_helper'

class ProductReviewTest < ActiveSupport::TestCase
  fixtures :products
  
  setup do
    @product = products(:usbkey)
    @review = {rating:4, author:"AZ199191", published_at:Date.parse("1 octobre 2013"), content:"Super!", product_id:@product.id}
  end
  
  test "only one review per author for a given product" do
    assert_difference('ProductReview.count', 1) do
      2.times { 
        review = ProductReview.new(@review)
        review.save
      }
    end
  end
  
end
