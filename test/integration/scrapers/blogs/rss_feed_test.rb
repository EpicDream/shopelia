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
  
  test "force feed to atom 2.0" do
    parser = Scrapers::Blogs::RSSFeed.new("http://www.lapenderiedechloe.com/")
    parser.expects(:post_from_atom_2)
    parser.items
  end
  
  test "get html link from feed, by force to atom 2.0" do
    parser = Scrapers::Blogs::RSSFeed.new("http://www.lapenderiedechloe.com/")
    item = parser.items.last
    
    assert_equal "http://www.lapenderiedechloe.com/2013/10/gemo.html", item.link
  end
  
end

  