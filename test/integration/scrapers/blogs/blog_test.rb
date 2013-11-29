# encoding: UTF-8

require 'test__helper'
require 'scrapers/blogs/blog'

class Scrapers::Blogs::BlogTest < ActiveSupport::TestCase
  
  setup do
    @blog = Scrapers::Blogs::Blog.new
  end
  
  test "check posts for each site" do
    skip
    missing = {}
    Scrapers::Blogs::URLS.each do |url|
      @blog.url = url
      posts = @blog.posts
      missing[url] = ["No posts for #{url}"] if posts.none?
      posts.each do |post|
        errors = []
        errors << "Missing Content : #{post.link}" if (post.content.blank? && post.description.blank?) rescue nil
        errors << "Missing Images : #{post.link}" if post.images.none?
        errors << "Missing Date : #{post.link}" if post.published_at.nil?
        errors << "Missing Link" if post.link.nil?
        missing[url] = errors if errors.any?
      end
    end
    puts missing.inspect
  end
  
  test "blog lesdessousdemarine" do
    @blog.url = "http://www.lesdessousdemarine.com/"
    @blog.posts.each do |post|
      assert !post.link.blank?
      assert post.images.count > 0
      assert post.published_at
    end
  end

  test "blog" do
    skip
    @blog.url = "http://www.marieluvpink.com/"
    @blog.posts.each do |post|
      puts post.title
      puts post.products.inspect
      puts post.images.inspect
    end
  end
  
end

  