# encoding: UTF-8

require 'test_helper'
require 'scrapers/blogs/blog'

class Scrapers::Blogs::ScraperTest < ActiveSupport::TestCase
  
  setup do
    @scraper = Scrapers::Blogs::Scraper.new
    @scraper.url = "http://www.leblogdebetty.com/"
    @@posts ||= @scraper.posts 
    @post = @@posts.first
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
    products = @@posts.last.products
    assert products.count >= 1
  end
  
  test "scrape date, link and title" do
    assert @post.title.length >= 2
    assert @post.published_at >= Date.parse("2012-01-01")
    assert @post.link =~ /http:\/\/www.leblogdebetty/
  end
  
  test "scrape date for http://www.alamode2sasou.com/" do
    @scraper.url = "http://www.alamode2sasou.com/"
    posts = @scraper.posts
    assert posts.first.published_at >= Date.parse("2012-01-01")
  end
  
  test "scrape date for http://www.adenorah.com/" do
    @scraper.url = "http://www.adenorah.com/"
    posts = @scraper.posts
    assert posts.first.published_at >= Date.parse("2012-01-01")
  end
  
  test "complete post link with base url if relative" do
    @scraper.url = "http://www.lesdessousdemarine.com/"
    post = @scraper.posts.first
    assert_match /lesdessousdemarine\.com/, post.link
  end
  
  test "scrape products links inside map tags" do
    @scraper.url = "http://www.leblogdebetty.com/mcq/"
    post = @scraper.posts.first
    products = post.products
    
    assert_equal 5, products.count
    assert_equal "http://bit.ly/1cal3V7", products["Produit(4)"]
  end
  
  test "load page from iframe source (blogspot)" do
    @scraper.url = "http://chicfashionworld.com/"
    posts = @scraper.posts
    
    assert posts.count > 0
    assert_not_match /(http.*){2,}/, posts.first.link 
  end
  
  ###### Skipped Tests for CI Semaphore ######
  
  test "scrape post when content in rss feed is not complete(can happen with feedburner)" do
    skip
    blog = Scrapers::Blogs::Blog.new
    blog.url = "http://www.leblogdebetty.com/"
    
    blog.posts.each do |post|
      assert !post.content.empty?
      assert post.images.count >= 1
    end
  end
  
  test "new block content markup" do
    skip
    @scraper.url = "http://www.yuyufashionbook.com"
    posts = @scraper.posts
    posts.each do |post|
      assert post.content.size > 10
      assert post.images.count >= 1
    end
  end
  
  test "search images in blog post link and from node parent if images <= 1" do
    skip
    @scraper.url = "http://www.lesdessousdemarine.com"
    posts = @scraper.posts
    posts.each do |post|
      assert post.images.count > 1
    end
  end
  
  test "add base url to images if relative" do
    skip
    @scraper.url = "http://personaluniform.creatorsofdesire.com/melancholy-phnom-penh/"
    posts = @scraper.posts
    posts.each do |post|
      assert post.images.count > 1
      assert post.images.last =~ /http:\/\/personaluniform.creatorsofdesire.com\//
    end
  end
  
  test "scrape images in sucking iframes" do
    skip
    @scraper.url = "http://anisasojka.com/post/74823909689/outfit-post-25-sporty-spice-click-on-the"
    posts = @scraper.posts
    posts.each do |post|
      assert post.images.count >= 2
      assert post.images.last =~ /media.tumblr.com.*?jpg/
    end
    
  end
  
end

  