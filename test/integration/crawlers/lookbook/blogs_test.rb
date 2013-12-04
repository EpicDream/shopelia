# encoding: UTF-8

require 'test_helper'
require 'crawlers/lookbook/blogs'

class Crawlers::Lookbook::BlogsTest < ActiveSupport::TestCase
  
  setup do
    @crawler = Crawlers::Lookbook::Blogs.new
    @@items ||= @crawler.items(max_page:1)
  end
  
  test "fetch all pages of items using thumb view and forging XHR requests" do
    skip
    items = @crawler.items
    assert_equal 190, items.count
  end
  
  test "blogger from item" do
    blog = @crawler.blog(@@items.first)

    assert_equal "Leeloo P", blog.name
    assert_equal "http://ledressingdeleeloo.blogspot.com/", blog.url
    assert_match /small\/93491_17/, blog.avatar_url
    assert_equal "FR", blog.country
    assert !blog.scraped
  end

end

  