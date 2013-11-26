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
  
  test "blog" do
    @blog.url = "http://www.lauraoupas.com/"
    puts @blog.posts.inspect
  end
  
end

  