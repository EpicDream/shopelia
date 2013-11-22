# encoding: UTF-8

require 'test__helper'
require 'scrapers/blogs/blog'

class Scrapers::Blogs::ScraperTest < ActiveSupport::TestCase
  
  setup do
    @scraper = Scrapers::Blogs::Scraper.new
    @scraper.url = "http://www.leblogdebetty.com/"
    @@posts ||= @scraper.posts 
    @post = @@posts.first
  end
  
  test "scrape post when content in rss feed is not complete(can happen with feedburner)" do
    skip
    blog = Scrapers::Blogs::Blog.new
    blog.url = "http://www.leblogdebetty.com/"
    
    blog.posts.each do |post|
      assert !post.content.empty?
      assert post.images.count >= 1
    end
  end
  
  test "scrape posts(when no feed)" do
    @scraper.url = "http://www.adenorah.com/"
    posts = @scraper.posts
    
    assert posts.count > 1
  end
    
  test "scrape images urls of post" do
    urls = @post.images
    assert urls.count > 1
    urls.each { |url| assert url =~ /http:\/\/farm.*\.staticflickr.com/ }
  end
  
  test "scrape texts blocks of post" do
    content = @post.content
    assert content.length >= 10
  end
  
  test "scrape any product url" do
    products = @post.products
    assert products.count >= 1
  end
  
end

  