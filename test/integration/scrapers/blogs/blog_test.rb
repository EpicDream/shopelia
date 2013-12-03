# encoding: UTF-8

require 'test_helper'
require 'scrapers/blogs/blog'

class Scrapers::Blogs::BlogTest < ActiveSupport::TestCase
  
  setup do
    @blog = Scrapers::Blogs::Blog.new
  end

  test "blog" do
    @blog.url = "http://www.natachasteven.com"
    posts = @blog.posts
    
    assert posts.count > 0
    posts.each do |post|
      assert !post.link.blank?
      assert post.images.count > 0
      assert post.published_at
    end
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

  