# encoding: UTF-8

require 'test__helper'
require 'scrapers/blogs/blog'

class Scrapers::Blogs::BlogTest < ActiveSupport::TestCase
  
  setup do
    @blog = Scrapers::Blogs::Blog.new
  end
  
  test "find articles blocks for each site" do
    skip
    missing = []
    Scrapers::Blogs::URLS.each do |url|
      @blog.url = url
      posts = @blog.posts
      missing << url if posts.count.zero?
    end
    
    assert missing.empty?, "Some blogs have no posts : #{missing.inspect}"
  end
  
end

  