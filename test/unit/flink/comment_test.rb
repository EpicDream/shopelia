require 'test_helper'

class CommentTest < ActiveSupport::TestCase

  setup do
    @flinker = flinkers(:betty)
    @look = looks(:agadir)
    can_be_posted(false)
  end

  test "create comment then post the comment on blog with formatted body" do
    skip #post on blog feature temp disabled
    Sidekiq::Testing.inline! do
      can_be_posted(true)
      
      assert_difference 'Comment.count' do
        comment = Comment.new(body: "trop belle", flinker_id:@flinker.id, look_id:@look.id)
        comment.post_to_blog = true
        comment.save
      end
    
      assert Comment.last.posted?
    end
  end
  
  test "create comment should create comment activity for flinker followers" do
    flinker = flinkers(:boop)
    follow(flinker, flinkers(:elarch))
    follow(flinker, flinkers(:fanny))
    
    assert_difference('CommentActivity.count', 2) do
      Comment.create(flinker_id:flinker.id, body:"comment", look_id:@look.id)
    end
    
    activity = CommentActivity.last
    assert_equal flinker, activity.flinker
    assert flinker.friends.include?(activity.target)
    assert_equal Comment.last, activity.resource
  end
  
  test "create comment should create mention activity for flinker if a flinker username is mentionned in comment" do
    text = "Salut @Lilou super ton look, regardez ça @boop et @non_flinker!"
    
    assert_difference('MentionActivity.count', 2) do
      Comment.create(flinker_id:@flinker.id, body:text, look_id:@look.id)
    end
    
    assert_equal [flinkers(:lilou), flinkers(:boop)].to_set, MentionActivity.all.map(&:target).to_set

    activity = MentionActivity.last
    assert_equal @flinker, activity.flinker
    assert_equal flinkers(:boop), activity.target
    assert_equal Comment.last, activity.resource
  end
  
  test "dont create comment if flinker is blacklisted" do
    flinker = flinkers(:fanny)
    flinker.can_comment = false
    flinker.save!
    assert_no_difference 'Comment.count' do
      assert_no_difference('CommentActivity.count') do
        Comment.create(body: "trop belle", flinker_id:flinker.id, look_id:@look.id)
      end
    end
  end
  
  test "extract hashtags and assign to look" do
    assert_difference("Hashtag.count", 2) do
      Comment.create(body: "#tropBelle #top pluie", flinker_id:@flinker.id, look_id:@look.id)
    end
    @look.reload
    
    assert_equal 2, @look.hashtags.count
    assert_equal ["tropBelle", "top"].to_set, @look.hashtags.map(&:name).to_set
  end
   
  private
  
  def can_be_posted can
    Comment.any_instance.stubs(:can_be_posted_on_blog?).returns(can)
    stubs_poster if can
  end
  
  def stubs_poster
    commenter = Poster::Comment.new
    commenter.expects(:deliver).returns(true)
    Poster::Comment.expects(:new).with(comment).returns(commenter)
  end

  def comment
    {:comment=>"trop belle <br/> sent via  <a href='http://flink.io'>Flink app</a>", :author=>"bettyusername", :email=>"flinkhq@gmail.com", :post_url=>"http://www.bla.com"}
  end

end
