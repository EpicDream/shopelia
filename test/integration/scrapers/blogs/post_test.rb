# encoding: UTF-8

require 'test_helper'
require 'scrapers/blogs/blog'

class Scrapers::Blogs::PostTest < ActiveSupport::TestCase
  
  setup do
  end
  
  test "convert scraper post to post model" do
    post = Scrapers::Blogs::Post.new
    post.published_at = Time.now
    post.link = "htpp://"
    post.images = ["http://blog.com/image_1.jpg"]
    
    mpost = post.modelize()
    assert_equal post.published_at, mpost.published_at
    assert_equal post.link, mpost.link
    assert_equal post.images, mpost.images
  end
end