require 'test_helper'

class FlinkerAuthenticationTest < ActiveSupport::TestCase

  setup do
    @fanny = flinker_authentications(:fanny)
    @flinker = flinkers(:fanny)
  end
  
  test "create new fb auth and new flinker" do
    @flinker.update_attributes(name:nil)
    fanny = { token:@fanny.token, uid:@fanny.uid } and @fanny.destroy and @flinker.destroy
    flinker = nil
    
    assert_difference("FlinkerAuthentication.count") { 
      flinker = FlinkerAuthentication.facebook(fanny[:token])
      flinker.reload
    }
    
    assert auth = flinker.flinker_authentications.first
    assert_equal fanny[:uid], auth.uid
    assert_equal "facebook", auth.provider
    assert_equal fanny[:token], auth.token
    assert_equal "https://graph.facebook.com/1583562383/picture?width=200&height=200&type=normal", auth.picture
    assert_equal "fanny.louvel@wanadoo.fr", auth.email
    assert_equal auth.email, flinker.email
    assert_equal 'LOUVEL.F', flinker.username
    assert_equal 'Fanny Louvel', flinker.name
    assert_match /images\/flinker\/\d+\/original\/avatar.jpg/, flinker.avatar.url
  end
  
  test "retrieve fb auth if exists with same uid" do
    @fanny.update_attributes(flinker_id:flinkers(:lilou).id)
    flinker = nil
    
    assert_no_difference("FlinkerAuthentication.count") { 
      flinker = FlinkerAuthentication.facebook(@fanny.token) 
    }
    
    assert_equal @fanny, flinker.flinker_authentications.first
    assert_equal flinkers(:lilou), flinker
  end
  
  test "update auth token and avatar" do
    token  = @fanny.token
    assert @fanny.update_attributes(token:"oldtoken", picture:nil)

    flinker = FlinkerAuthentication.facebook(token) 
    
    auth = flinker.flinker_authentications.first
    assert_equal token, auth.token
    assert_match /images\/flinker\/\d+\/original\/avatar.jpg/, flinker.avatar.url
  end
  
  test "if flinker with same email as facebook one exists attach auth to it" do
    token  = @fanny.token and @fanny.destroy

    assert_no_difference("Flinker.count") { FlinkerAuthentication.facebook(token) }
    
    auth = FlinkerAuthentication.where(uid:"1583562383").first
    assert_equal @flinker, auth.flinker
  end
  
  test "refresh token" do
    @fanny.refresh_token!("new_token")
    
    assert_equal "new_token", @fanny.reload.token
  end
  
  test "update avatar from provider avatar if flinker has default avatar" do
    FlinkerAuthentication.facebook(@fanny.token)
    
    @flinker.reload
    assert_match /images\/flinker\/\d+\/original\/avatar.jpg/, @flinker.avatar.url
  end
  
  test "does not update avatar if flinker has one which is not the default one" do
    @flinker.avatar_url = "https://www.smartangels.fr/bundles/theodosmartangels/images/default-avatar.png"
    @flinker.save!
    
    @flinker.expects(:avatar_url=).never
    FlinkerAuthentication.facebook(@fanny.token)
  end
  
  test "auto follow flinkers who are facebook friends, reciprocally and send apn to followers" do
    Sidekiq::Testing.inline! do
      FollowNotificationWorker.unstub(:perform_in)
      flinkers = Flinker.all

      ["523331154", "524109067", "525274445"].each_with_index { |uid, index|
        FlinkerAuthentication.create!(uid:uid, flinker_id:flinkers[index].id)
      }

      flinkers[0..2].each { |flinkr| 
        Flink::FollowNotification.expects(:new).with(flinkr, flinkers(:fanny)).returns(stub(:deliver => nil))
      }
    
      flinker = FlinkerAuthentication.facebook(@fanny.token)
      assert_equal 3, flinker.followings.count
    
      flinkers[0..2].each { |flinkr| 
        assert flinkr.followings.include?(flinker) 
      }
    end
  end
  
  test "update flinker username from facebook if none" do
    @flinker.update_attributes(name:nil)

    flinker = FlinkerAuthentication.facebook(@fanny.token) 
    
    assert_equal 'Fanny Louvel', @flinker.reload.name
  end

end