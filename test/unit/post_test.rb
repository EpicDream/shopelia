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

  test "it should convert to look" do
    @post.products = {"Amazon"=>"http://www.amazon.fr/dp/B00BIXXTCY","Other"=>"http://www.other.com"}.to_json
    @post.images = ["http://farm4.staticflickr.com/3681/10980880355_0a0151fbd1_o.jpg", "http://4.bp.blogspot.com/-GGA8yv0lU8U/UPuvNd5LAlI/AAAAAAAAJmk/DSvdiYMmbYI/s1600/signature.png"].to_json
    
    assert_difference ["Look.count","Product.count","Event.count","LookProduct.count"] do
      @post.save
    end

    assert_equal 1, @post.links.count

    look = @post.look
    assert_equal "test", look.name
    assert_equal "http://www.toto.fr", look.url
    assert_equal 2, look.look_images.count
    assert_not_nil look.published_at 
  end

  test "it shouln't create look if less than two image" do
    @post.images = ["http://farm4.staticflickr.com/3681/10980880355_0a0151fbd1_o.jpg"].to_json
    @post.save
    assert @post.look.nil?
  end    
end