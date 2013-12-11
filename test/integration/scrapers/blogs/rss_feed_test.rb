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
    
    assert_match /lapenderiedechloe.com\/201\d\/\d\d\//, item.link
  end
  
  test "Atom 1.0 : dont get rss link url for a post, get html link" do
    skip
    urls = ["http://www.adenorah.com", "http://www.youmakefashion.fr", "http://wonder-is-forever-young.blogspot.com", "http://www.thelittleworldoffashion.fr", "http://www.alamode2sasou.com"]
    urls.each do |url|
      @blog.url = url
      posts = @blog.posts
      assert(posts.none?{ |post| puts post.link;post.link =~ /feeds/ }, "Failure with #{url}")
    end
  end
  
  test "generate incident if a post link is rss link" do
    parser = Scrapers::Blogs::RSSFeed.new("")
    Incident.expects(:create)
    post = Post.new(link:"http://www.adenorah.com/2013/11/feeds/toto/titi")
    parser.stubs(:post_from_atom_1).returns(post)
    parser.send(:post_from, stub)
  end
  
end

  