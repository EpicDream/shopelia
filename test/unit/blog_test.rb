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
end
