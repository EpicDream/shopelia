require 'test__helper'

class BlogTest < ActiveSupport::TestCase
  
  test "create flinker and assign to blog if none" do
    blog = Blog.create(url:"http://fashion.fr")
    
    assert blog.flinker
  end
  
  test "do not assign new flinker if blog created with flinker reference" do
    flinker = Flinker.create(name:"fashion", url:"http://fashion.fr")
    
    Flinker.expects(:create).never
    blog = Blog.create(url:"http://fashion.fr", flinker_id:flinker.id)
    
    assert_equal flinker, blog.flinker
  end
  
  test "uniqueness on url with slash tail" do
    assert Blog.create(url:"http://miss.com")
    
    assert_difference('Blog.count', 0) do
      Blog.create(url:"http://miss.com/")
    end
  end
end
