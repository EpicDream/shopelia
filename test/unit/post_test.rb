require 'test_helper'

class PostTest < ActiveSupport::TestCase
  
  test "clean products url before create" do
    post = Post.new(link: "http://www.toto.fr", blog_id: blogs(:betty).id)
    post.products = {"jupe" => "http://bit.ly/17uPRlU"}.to_json
    
    Linker.expects(:clean).with("http://bit.ly/17uPRlU")
    Linker.expects(:clean).with("http://www.toto.fr")
    post.save!

    assert_equal "pending", post.status
  end

  test "it should convert to products and links" do
    post = Post.new(link: "http://")
    post.products = {"Amazon"=>"http://www.amazon.fr/dp/B00BIXXTCY","Other"=>"http://www.other.com"}.to_json
    
    assert_difference ["Product.count","Event.count"] do
      @products, @links = post.convert
    end

    assert_equal 1, @products.count
    assert_equal 1, @links.count
  end

  test "it should create look" do
    post = Post.create(link: "http://www.toto.fr", title:"Name", published_at:Time.now, products:{}.to_json, blog_id: blogs(:betty).id)

    assert_difference "Look.count" do
      @look = post.generate_look
    end

    assert_equal "Name", @look.name
    assert_equal "http://www.toto.fr", @look.url
    assert_not_nil @look.published_at 
  end
end
