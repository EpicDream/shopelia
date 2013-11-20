# encoding: UTF-8

require 'test__helper'
require 'scrapers/blogs/scraper'

class Scrapers::Blogs::ScraperTest < ActiveSupport::TestCase
  
  setup do
    @scraper = Scrapers::Blogs::Scraper.new
    @scraper.url = "http://www.leblogdebetty.com/"
    @@posts ||= @scraper.posts
  end
    
  test "scrape images urls of post" do
    urls = @scraper.images @@posts.first
    
    assert urls.count > 1
  end
  
  test "scrape texts blocks of post" do
    texts = @scraper.texts @@posts.first
    puts texts.inspect
    assert texts.count >= 1
  end
  
  test "find articles blocks for each site" do
    skip
    Scrapers::Blogs::URLS.each do |url|
      @scraper.url = url
      assert @scraper.posts.count > 0, "no entries found for url #{url}"
    end
  end
  
end

  