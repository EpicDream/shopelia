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
  
  test "fetch all pages of items using thumb view and forging XHR requests for US" do
    skip
    Country.create(:id=>233,:iso=>"US",:name=>"United States")
    @crawler = Crawlers::Lookbook::Blogs.new("united-states")
    items = @crawler.items
    assert_equal 360, items.count
  end
  
  test "blogger from item" do
    blog = @crawler.blog(@@items.first)

    assert blog.name.length > 2
    assert_match /http:\/\//, blog.url
    assert blog.avatar_url
    assert_equal "FR", blog.country
    assert blog.scraped
  end

end

  