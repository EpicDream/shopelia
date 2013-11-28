require 'test_helper'

class PostTest < ActiveSupport::TestCase
  
  test "clean products url before create" do
    post = Post.new(link: "http://www.toto.fr")
    post.products = {"jupe" => "http://bit.ly/17uPRlU"}.to_json
    
    Linker.expects(:clean).with("http://bit.ly/17uPRlU")
    Linker.expects(:clean).with("http://www.toto.fr")
    
    post.save!
  end
end
