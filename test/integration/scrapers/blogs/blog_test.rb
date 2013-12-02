# encoding: UTF-8

require 'test_helper'
require 'scrapers/blogs/blog'

class Scrapers::Blogs::BlogTest < ActiveSupport::TestCase
  TEST_URL = "http://www.leblogdelilou.com/"
  
  setup do
    @blog = Scrapers::Blogs::Blog.new
  end

  test "blog" do
    @blog.url = TEST_URL
    posts = @blog.posts
    
    assert posts.count > 0
    posts.each do |post|
      assert !post.link.blank?
      assert post.images.count > 0
      assert post.published_at
    end
  end
  
end

  