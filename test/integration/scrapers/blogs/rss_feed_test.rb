# encoding: UTF-8

require 'test__helper'
require 'scrapers/blogs/blog'

class Scrapers::Blogs::RSSFeedTest < ActiveSupport::TestCase
  
  setup do
  end

  test "atom 2.0 feed" do
    parser = Scrapers::Blogs::RSSFeed.new("http://kenzasmg.blogspot.fr")
    
    assert parser.items.count >= 1
  end
  
  test "atom 1.0 feed" do
    parser = Scrapers::Blogs::RSSFeed.new("http://www.madeinfaro.com/")
    assert item = parser.items.first
    
    assert item.images.any?
    assert item.title.length > 2
    assert item.content.length > 10
    assert item.categories.compact.count >= 1
  end
end

  