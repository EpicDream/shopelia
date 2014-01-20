require 'test_helper'

class CommentTest < ActiveSupport::TestCase

  setup do
    @flinker = flinkers(:betty)
  end

   test "should format comment" do
     comment = Comment.create(body: "trop belle", flinker_id:@flinker.id)
     assert_ comment.format_comment
   end

end
