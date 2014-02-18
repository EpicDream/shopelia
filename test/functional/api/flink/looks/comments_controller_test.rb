require 'test_helper'

class Api::Flink::Looks::CommentsControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  
  setup do
    Comment.any_instance.stubs(:can_be_posted_on_blog?).returns(true)
    Poster::Comment.any_instance.stubs(:deliver).returns(true)
    Comment.destroy_all
    Look.destroy_all
    @flinker = flinkers(:lilou)
    build_look
  end

  test "should get comments of a post index" do
    build_comments
    
    get :index, look_id: @look.uuid, format: :json
    assert_response :success
    assert_equal 20, json_response["comments"].count
  end

  test "should create a comment" do
    sign_in @flinker

    assert_difference(['Comment.count']) do
      post :create, look_id:@look.uuid, comment: {
          body: "Radieuse <3",
      }, format: :json
    end
    
    comment = Comment.find(json_response["comment"]["id"])
    
    assert_response 201
    assert_equal comment.flinker_id, @flinker.id
    assert_equal comment.look_id, @look.id
  end
  
  test "if device is development device, comment must not be posted to blog" do
    stubs_retrieve_device_returns_dev_device
    sign_in @flinker
    Comment.any_instance.expects(:post_comment_on_blog_async).never
    
    post :create, look_id:@look.uuid, comment: { body: "Radieuse <3" }, format: :json
  end

  private
  
  def stubs_retrieve_device_returns_dev_device
    Api::Flink::BaseController.class_eval do
      def retrieve_device
        @device = Device.new(is_dev:true, is_beta:true)
      end
    end
  end

  def build_comments
    build_look
    (1..20).to_a.each do |i|
      build_comment(i.to_s,@look)
    end
  end

  def build_comment body,look
    look.comments.create!(
        body: body,
        flinker_id: @flinker.id,
    )
  end

  def build_look
    @look = Look.create!(
        name:"Article",
        flinker_id:@flinker.id,
        published_at:1.day.ago,
        is_published:true,
        url:"http://www.leblogdebetty.com/article")
  end

end
