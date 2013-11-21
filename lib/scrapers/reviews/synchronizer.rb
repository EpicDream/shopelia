# -*- encoding : utf-8 -*-
module Scrapers
  module Reviews
    class Synchronizer
      def self.synchronize review
        return if review[:author].nil? #économise une requête ...
        review = ProductReview.new(review)
        review.save
      end
    end
  end
end