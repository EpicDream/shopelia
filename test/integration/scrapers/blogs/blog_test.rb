# encoding: UTF-8

require 'test_helper'
require 'scrapers/blogs/blog'

class Scrapers::Blogs::BlogTest < ActiveSupport::TestCase
  
  setup do
    Linker.stubs(:clean)
    @blog = Scrapers::Blogs::Blog.new
  end

  test "no exception when a post has no content" do
    Scrapers::Blogs::Scraper.any_instance.expects(:posts).never #from feed only
    @blog.url = "http://kenzasmg.blogspot.fr"
    posts = @blog.posts
    assert posts.count > 0
  end
  
  test "blog with summary access to posts" do
    @blog.url = "http://www.madeinfaro.com"
    posts = @blog.posts
    assert posts.count > 0
    posts.each do |post|
      assert !post.link.blank?
      assert post.published_at
    end
  end
  
  test "remove CDATA" do
    @blog.url = "http://www.modenmarie.com/"
    posts = @blog.posts
    posts.each do |post|
      assert !(post.content =~ /CDATA/)
    end
  end
  
end

  