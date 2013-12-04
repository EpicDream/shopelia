require 'test_helper'

class BlogTest < ActiveSupport::TestCase
  
  test "create batch of blogs from csv file and return created blogs" do
    csv = "http://www.leblogdebetty.com/,Betty\nhttp://www.adenorah.com/,Adenorah"
    blogs = []
    assert_difference("Blog.count", 2) do
      blogs = Blog.batch_create_from_csv(csv)
    end
    assert_equal 2, blogs.count
  end
  
  test "create flinker and assign to blog if none" do
    blog = Blog.create(url:"http://fashion.fr")
    
    assert blog.flinker
  end
  
  test "do not assign new flinker if blog created with flinker reference" do
    flinker = Flinker.create(name:"fashion",url:"http://fashion.fr")
    
    Flinker.expects(:create).never
    blog = Blog.create(url:"http://fashion.fr", flinker_id:flinker.id)
    
    assert_equal flinker, blog.flinker
  end
end
