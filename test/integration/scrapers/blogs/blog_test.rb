# encoding: UTF-8

require 'test__helper'
require 'scrapers/blogs/blog'

class Scrapers::Blogs::BlogTest < ActiveSupport::TestCase
  
  setup do
    @blog = Scrapers::Blogs::Blog.new
  end
  
  test "find articles blocks for each site" do
    #skip
    Scrapers::Blogs::URLS[11..-1].each do |url|
      @blog.url = url
      posts = @blog.posts
      assert posts.count > 0, "no entries found for url #{url}"
      puts url
    end
  end
  
end

  