# encoding: UTF-8

require 'test_helper'
require 'crawlers/lookbook/blogs'

class Crawlers::Lookbook::BlogsTest < ActiveSupport::TestCase
  
  setup do
    @crawler = Crawlers::Lookbook::Blogs.new
  end
  
  test "fetch" do
    items = @crawler.run
    assert_equal 13, items.count
  end

end

  