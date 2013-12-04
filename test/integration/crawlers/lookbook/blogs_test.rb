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
    blogger = @crawler.blogger(@@items.first)

    assert_equal "Louise Ebel", blogger.name
    assert_equal "http://www.misspandora.fr", blogger.blog_url
    assert_match /small\/2710_5139406926_02c3347e7a_b.jpg/, blogger.avatar_url
    assert_equal "france", blogger.country
  end

end

  