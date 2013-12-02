# encoding: UTF-8

require 'test_helper'
require 'scrapers/blogs/blog'

class Scrapers::Blogs::BlogTest < ActiveSupport::TestCase
  
  setup do
    @blog = Scrapers::Blogs::Blog.new
  end

  test "blog lesdessousdemarine" do
    @blog.url = "http://www.lesdessousdemarine.com/"
    @blog.posts.each do |post|
      assert !post.link.blank?
      assert post.images.count > 0
      assert post.published_at
    end
  end
  
end

  