require 'social/twitter/twitter_connect'

class TwitterAuthentication < FlinkerAuthentication
  TWITTER = "twitter"
  
  def self.authenticate token, token_secret, email=nil
    client = TwitterConnect.new(token, token_secret)
    created = false
    user = client.me
    picture = user.profile_image_uri(:bigger)
    picture = picture.to_s.gsub(/_bigger/, '') if picture
    auth = where(uid:user.id.to_s).first 
    auth and auth.update_attributes!(user:user, picture:picture) and auth.after_sign_in
    
    unless auth
      auth = create!(uid:user.id, email:email, token:token, picture:picture, provider:TWITTER, token_secret: token_secret) 
      auth.user = user
      auth.after_sign_up
      created = true
    end
    auth.refresh_tokens!(token, token_secret)
    [auth.flinker, created]
  end
  
  def refresh_tokens! token, token_secret
    update_attributes!(token:token, token_secret: token_secret)
  end
  
  def after_sign_up
    after_sign_in
  end
  
  def after_sign_in
    flinker or assign_flinker or create_flinker
    update_flinker_avatar
  end
  
  def update_flinker_avatar
    return unless flinker.avatar.url =~ /missing/
    flinker.avatar_url = self.picture
    flinker.save!
  end
  
  private
  
  def assign_flinker 
    return unless flinker = Flinker.where(email:self.email).first 
    self.update_attributes!(flinker_id:flinker.id)
    flinker
  end
  
  def create_flinker
    password = SecureRandom.hex(4)
    username = user.screen_name
    if Flinker.where('username ~* ?', "^#{username}$").first
      username = "#{username}#{SecureRandom.hex(1)}"
    end
    flinker = Flinker.create!(email:self.email, name:user.name, username:username, password:password, password_confirmation:password)
    self.update_attributes!(flinker_id:flinker.id)
    flinker
  end
  
end