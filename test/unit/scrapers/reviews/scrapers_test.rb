# -*- encoding : utf-8 -*-
require 'test__helper'
require 'scrapers/reviews/scrapers'

class Scrapers::Reviews::ScrapersTest < ActiveSupport::TestCase
  
  setup do
    @product = Product.new
    @product.id = 1
  end
  
  test "scraper module for domain amazon" do
    klass = Scrapers::Reviews.scraper('amazon')
    assert_equal Scrapers::Reviews::Amazon::Scraper, klass
  end
  
  test "scraper module for domain priceminister" do
    klass = Scrapers::Reviews.scraper('priceminister')
    assert_equal Scrapers::Reviews::Priceminister::Scraper, klass
  end
  
  test "scrape find merchant via product from amazon" do
    @product.stubs(:merchant).returns(stub(domain:'amazon.fr'))
    
    Scrapers::Reviews.requires('amazon')
    Scrapers::Reviews::Amazon::Scraper.expects(:scrape).with(@product.id)
    Scrapers::Reviews.scrape(@product)
  end
  
  test "scrape find merchant via product from priceminister" do
    @product.stubs(:merchant).returns(stub(domain:'priceminister.com'))
    
    Scrapers::Reviews.requires('priceminister')
    Scrapers::Reviews::Priceminister::Scraper.expects(:scrape).with(@product.id)
    Scrapers::Reviews.scrape(@product)
  end

end
