require 'test_helper'

class FlinkerAuthenticationTest < ActiveSupport::TestCase

  setup do
    @fanny = flinker_authentications(:fanny)
  end
  
  test "create new fb auth and new flinker" do
    fanny = { token:@fanny.token, uid:@fanny.uid } and @fanny.destroy
    flinker = nil
    
    assert_difference("FlinkerAuthentication.count") { 
      flinker = FlinkerAuthentication.facebook(fanny[:token]) 
    }
    
    assert auth = flinker.flinker_authentications.first
    assert_equal fanny[:uid], auth.uid
    assert_equal "facebook", auth.provider
    assert_equal fanny[:token], auth.token
    assert_equal "https://graph.facebook.com/1583562383/picture", auth.picture
    assert_equal "fanny.louvel@wanadoo.fr", auth.email
    assert_equal auth.email, flinker.email
    assert_equal 'LOUVEL.F', flinker.username
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
  
  test "update auth token" do
    token  = @fanny.token
    assert @fanny.update_attributes(token:"oldtoken")

    flinker = FlinkerAuthentication.facebook(token) 
    
    auth = flinker.flinker_authentications.first
    assert_equal token, auth.token
  end
  
  test "if flinker with same email as facebook one exists attach auth to it" do
    token  = @fanny.token and @fanny.destroy
    flinker = Flinker.create(email: "fanny.louvel@wanadoo.fr", password: "password", password_confirmation:"password")

    assert_no_difference("Flinker.count") { FlinkerAuthentication.facebook(token) }
    
    auth = FlinkerAuthentication.where(uid:"1583562383").first
    assert_equal flinker, auth.flinker
  end

end