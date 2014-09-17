# encoding: UTF-8
require 'test_helper'
require 'scrapers/blogs/date'

class Scrapers::Blogs::DateTest < ActiveSupport::TestCase
  
  setup do
  end
  
  test "extract date from date node time" do
    document = Nokogiri::HTML("<html><body><time datetime='2014-01-09 15:52:29 +0100'></time></body></html>")
    date = Scrapers::Blogs::Date.new(document).extract

    assert_equal "2014-01-09", date.to_s
  end
  
  test "extract date from date node with itemprop datePublished" do
    document = Nokogiri::HTML("<html><body><span itemprop='datePublished' title='2014-01-09 15:52:29 +0100'></span></body></html>")
    date = Scrapers::Blogs::Date.new(document).extract

    assert_equal "2014-01-09", date.to_s
  end
  
  test "extract date from text" do
    document = Nokogiri::HTML("<html><body><p>12 Décembre 2013</p></body></html>")
    date = Scrapers::Blogs::Date.new(document).extract

    assert_equal "2013-12-12", date.to_s
  end
  
  test "extract date from text with month first" do
    document = Nokogiri::HTML("<html><body><p> Dezember 20 2013</p></body></html>")
    date = Scrapers::Blogs::Date.new(document).extract

    assert_equal "2013-12-20", date.to_s
  end
  
end