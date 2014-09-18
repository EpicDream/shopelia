require 'test_helper'

class PostTest < ActiveSupport::TestCase
  fixtures :all

  setup do
    @post = Post.new(
      link: "http://www.toto.fr", 
      title:"test", 
      published_at:Time.now, 
      blog_id: blogs(:betty).id,
      content: "bla bla bla",
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
    
    assert_difference ["Look.count"] do
      @post.save
    end

    look = @post.look
    assert_equal "test", look.name
    assert_equal "http://www.toto.fr", look.url
    assert_equal 2, look.look_images.count
    assert_equal "bla bla bla", look.description
    assert_not_nil look.published_at 
  end

  test "it shouln't create look if less than two image" do
    @post.images = ["http://farm4.staticflickr.com/3681/10980880355_0a0151fbd1_o.jpg"].to_json
    @post.save
    assert @post.look.nil?
  end
  
  test "post must be unique by title" do
    assert_difference('Post.count', 1) do
      1.upto(3) { 
        @post = Post.new(title:"Fashion", link: "http://www.toto.fr", blog_id: blogs(:betty).id, products:{}.to_json, images:[].to_json, )
        @post.save
      }
    end
    assert_equal "http://www.toto.fr", Post.first.link
  end
  
  test "clean title long spaces ranges" do
    Linker.stubs(:clean).returns("http://www.fake.com")
    
    title = "\n\nCOFFEE... BUT NOT IN PARIS\n\n\n\n                                    — \n                                    \n                                      by\n                                    \nJessie Pink\n\n      "
    post = Post.new(link: "http://www.toto.fr", blog_id: blogs(:betty).id, title:title, products:{}.to_json, images:[].to_json)
    assert post.save
    post.reload
    assert_equal "COFFEE... BUT NOT IN PARIS — by Jessie Pink", post.title
  end
  
end