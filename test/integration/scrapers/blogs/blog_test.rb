# encoding: UTF-8

require 'test_helper'
require 'scrapers/blogs/blog'

class Scrapers::Blogs::BlogTest < ActiveSupport::TestCase
  
  setup do
    @blog = Scrapers::Blogs::Blog.new
  end

  test "no exception when a post has no content" do
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
      assert post.images.count > 0
      assert post.published_at
    end
    
  end
  
end

  