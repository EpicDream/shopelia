require 'test_helper'

class CommentTest < ActiveSupport::TestCase

  setup do
    @flinker = flinkers(:betty)
    @look = looks(:agadir)
    Sidekiq::Testing.inline!
  end

  test "create comment then post the comment on blog with formatted body" do
    stubs_poster
    Comment.any_instance.stubs(:can_be_posted_on_blog?).returns(true)
    
    assert_difference 'Comment.count' do
      comment = Comment.new(body: "trop belle", flinker_id:@flinker.id, look_id:@look.id)
      comment.post_to_blog = true
      comment.save
    end
    
    assert Comment.last.posted?
  end
   
  private
  
  def stubs_poster
    commenter = Poster::Comment.new
    commenter.expects(:deliver).returns(true)
    Poster::Comment.expects(:new).with(comment).returns(commenter)
  end

  def comment
    {:comment=>"bettyusername <br/> trop belle <br/> send via  <a href='http://flink.io'>flink</a>", :author=>"bettyusername", :email=>"flinkhq@gmail.com", :post_url=>"http://www.bla.com"}
  end

end
