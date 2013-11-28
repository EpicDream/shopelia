require 'test_helper'

class PostTest < ActiveSupport::TestCase
  
  test "clean products url before create" do
    post = Post.new(link: "http://")
    post.products = {"jupe" => "http://bit.ly/17uPRlU"}.to_json
    
    Linker.expects(:clean).with("http://bit.ly/17uPRlU")
    post.save!

    assert_equal "pending", post.status
  end
end