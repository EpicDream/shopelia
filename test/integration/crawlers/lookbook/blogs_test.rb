# encoding: UTF-8

require 'test_helper'
require 'crawlers/lookbook/blogs'

class Crawlers::Lookbook::BlogsTest < ActiveSupport::TestCase
  
  setup do
    @crawler = Crawlers::Lookbook::Blogs.new
  end
  
  test "fetch" do
    assert_equal 13, @crawler.items.count
  end

end

  