require 'test_helper'

class CommentTest < ActiveSupport::TestCase

  setup do
    @flinker = flinkers(:betty)
    @look = looks(:agadir)
  end

  test "create comment then post the comment on blog with formatted body" do
    Comment.any_instance.stubs(:can_be_posted_on_blog?).returns(true)
    commenter = Poster::Comment.new
    commenter.expects(:deliver).returns(true)
    Poster::Comment.expects(:new).with(comment).returns(commenter)
    
    assert_difference 'Comment.count' do
      Comment.create(body: "trop belle", flinker_id:@flinker.id, look_id:@look.id)
    end
    
    assert Comment.last.posted?
  end
   
  private

  def comment
    {:comment=>"bettyusername <br/> trop belle <br/> send via  <a href='http://flink.io'>flink</a>", :author=>"bettyusername", :email=>"hello@flink.io", :post_url=>"http://www.bla.com"}
  end

end
