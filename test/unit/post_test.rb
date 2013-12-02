require 'test_helper'

class PostTest < ActiveSupport::TestCase
  
  setup do
    @post = Post.new(
      link: "http://www.toto.fr", 
      title:"test", 
      published_at:Time.now, 
      blog_id: blogs(:betty).id,
      products:{}.to_json,
      images:[].to_json)
  end

  test "clean products url before create" do
    @post.products = {"jupe" => "http://bit.ly/17uPRlU"}.to_json
    
    Linker.expects(:clean).with("http://bit.ly/17uPRlU")
    Linker.expects(:clean).with("http://www.toto.fr")
    @post.save
  end

  test "it should convert to products and links" do
    @post.products = {"Amazon"=>"http://www.amazon.fr/dp/B00BIXXTCY","Other"=>"http://www.other.com"}.to_json
    @post.images = ["http://farm4.staticflickr.com/3681/10980880355_0a0151fbd1_o.jpg"].to_json
    
    assert_difference ["Look.count","Product.count","Event.count","LookProduct.count","LookImage.count"] do
      @post.save
    end

    assert_equal 1, @post.links.count
  end

  test "it should create look" do
    assert_difference "Look.count" do
      @look = @post.generate_look
    end

    assert_equal "test", @look.name
    assert_equal "http://www.toto.fr", @look.url
    assert_not_nil @look.published_at 
  end
end