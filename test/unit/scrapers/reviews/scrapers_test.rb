# -*- encoding : utf-8 -*-
require 'test__helper'
require 'scrapers/reviews/scrapers'

class Scrapers::Reviews::ScrapersTest < ActiveSupport::TestCase
  MERCHANTS = { "amazon" => "amazon.fr", "priceminister" => "priceminister.com", 
                "rue_du_commerce" => "rueducommerce.fr", "fnac" => "fnac.com" }
  
  setup do
    @product = Product.new
    @product.id = 1
  end
  
  test "scraper module for merchant domain" do
    MERCHANTS.keys.each { |merchant| run_scraper_module_spec_for(merchant) }
  end
  
  test "scrape find merchant via product" do
    MERCHANTS.keys.each { |merchant| run_scrape_find_merchant_via_product_spec_for(merchant)}
  end
  
  private
  
  def run_scrape_find_merchant_via_product_spec_for merchant
    @product.stubs(:merchant).returns(stub(domain:MERCHANTS[merchant]))
    
    Scrapers::Reviews.requires(merchant)
    klass = "Scrapers::Reviews::#{merchant.camelize}::Scraper".constantize
    klass.expects(:scrape).with(@product.id)
    Scrapers::Reviews.scrape(@product)
  end
  
  def run_scraper_module_spec_for merchant
    klass = Scrapers::Reviews.scraper(merchant)
    expected_klass = "Scrapers::Reviews::#{merchant.camelize}::Scraper".constantize
    
    assert_equal expected_klass, klass, "scraper module failure for #{merchant}"
  end
  
end
