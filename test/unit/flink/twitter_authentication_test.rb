require 'test_helper'

class TwitterAuthenticationTest < ActiveSupport::TestCase

  setup do
    @boop = flinker_authentications(:boop)
    @flinker = flinkers(:boop)
  end
  
  test "create new twitter auth and new flinker" do
    rescue_too_many_requests do
      boop = { token:@boop.token, token_secret:@boop.token_secret, uid:@boop.uid } and @boop.destroy and @flinker.destroy
      flinker = nil
    
      assert_difference("TwitterAuthentication.count") { 
        flinker, created = TwitterAuthentication.authenticate(boop[:token], boop[:token_secret], "boop@flink.io")
        flinker.reload
      }
    
      assert auth = flinker.flinker_authentications.first
      assert_equal boop[:uid], auth.uid
      assert_equal "twitter", auth.provider
      assert_equal boop[:token], auth.token
      assert_equal "http://pbs.twimg.com/profile_images/427788089512062976/XWGe-vtB.png", auth.picture
      assert_equal "boop@flink.io", auth.email
      assert_equal auth.email, flinker.email
      assert_equal 'FlinkHQ', flinker.username
      assert_equal 'Flink', flinker.name
      assert_match /images\/flinker\/\d+\/original\/avatar.jpg/, flinker.avatar.url
    end
  end
  
  test "retrieve twitter auth if exists with same uid and dont update email if nil passed" do
    rescue_too_many_requests do
      @boop.update_attributes(flinker_id:flinkers(:lilou).id)
      flinker = nil
    
      assert_no_difference("TwitterAuthentication.count") { 
        flinker, created = TwitterAuthentication.authenticate(@boop.token, @boop.token_secret)
      }
    
      assert_equal @boop, flinker.flinker_authentications.first
      assert_equal flinkers(:lilou), flinker
      assert_equal "boop@flink.com", @boop.email
    end
  end
  
  test "update auth token and avatar" do
    rescue_too_many_requests do
      token  = @boop.token
      token_secret = @boop.token_secret
      assert @boop.update_attributes(token:"oldtoken", token_secret:"oldone", picture:nil)
  
      flinker, created = TwitterAuthentication.authenticate(token, token_secret)
    
      auth = flinker.flinker_authentications.first
      assert_equal token, auth.token
      assert_match /images\/flinker\/\d+\/original\/avatar.jpg/, flinker.avatar.url
      assert_equal "boop@flink.com", @boop.email
    end
  end
  
  test "if flinker with same email as twitter one exists, attach auth to her" do
    rescue_too_many_requests do
      token, secret_token = @boop.token, @boop.token_secret
      @boop.destroy
  
      assert_no_difference("Flinker.count") { 
        TwitterAuthentication.authenticate(token, secret_token, "anne@flink.com") 
      }
    
      auth = TwitterAuthentication.where(uid:"2227040976").first
      assert_equal flinkers(:anne), auth.flinker
    end
  end
  
  test "refresh token" do
    @boop.refresh_tokens!("new_token", "new_token_secret")
    
    @boop.reload
    assert_equal "new_token", @boop.token
    assert_equal "new_token_secret", @boop.token_secret
  end
  
  test "update avatar from provider avatar if flinker has default avatar" do
    rescue_too_many_requests do
      TwitterAuthentication.authenticate(@boop.token, @boop.token_secret) 
    
      @flinker.reload
      assert_match /images\/flinker\/\d+\/original\/avatar.jpg/, @flinker.avatar.url
      assert_equal "boop@flink.com", @flinker.email
    end
  end
  
  test "does not update avatar if flinker has one which is not the default one" do
    rescue_too_many_requests do
      @flinker.avatar_url = "https://www.smartangels.fr/bundles/theodosmartangels/images/default-avatar.png"
      @flinker.save!
    
      @flinker.expects(:avatar_url=).never
      TwitterAuthentication.authenticate(@boop.token, @boop.token_secret) 
    end
  end
  
  private
  
  def rescue_too_many_requests
    yield
  rescue Twitter::Error::TooManyRequests
    skip
  end

end