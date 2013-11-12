module Scrapers
  module Reviews
    class Synchronizer
      def self.synchronize review
        review = ProductReview.new(review)
        review.save
      end
    end
  end
end