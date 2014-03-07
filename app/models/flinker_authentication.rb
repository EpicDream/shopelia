class FlinkerAuthentication < ActiveRecord::Base
  FACEBOOK = "facebook"
  act_as_flink_activity :facebook_friend_signed_up
  
  attr_accessible :provider, :uid, :token, :picture, :email, :flinker_id, :user
  attr_accessor :user
  
  belongs_to :flinker
  
  scope :facebook_of, ->(flinker) { where(flinker_id:flinker.id, provider:FACEBOOK).limit(1) }
  scope :with_uid, ->(uid) { where(uid:uid).limit(1) }
  
  def self.facebook token
    user = FbGraph::User.me(token).fetch

    auth = where(uid:user.identifier).first 
    picture = "#{user.picture}?width=200&height=200&type=normal"
    auth and auth.update_attributes!(user:user, picture:picture) and auth.after_sign_in
    unless auth
      auth = create!(uid:user.identifier, email:user.email, token:token, picture:picture, provider:FACEBOOK) 
      auth.user = user
      auth.after_sign_up
    end
    auth.refresh_token!(token)
    auth.flinker
  end
  
  def refresh_token! token
    update_attributes!(token:token)
  end
  
  def update_flinker_avatar
    return unless flinker.avatar.url =~ /missing/
    flinker.avatar_url = self.picture
    flinker.save!
  end
  
  def update_flinker_name
    return unless flinker.name.blank?
    flinker.name = user.name
    flinker.save!
  end
  
  def after_sign_up
    after_sign_in
    FacebookFriend.assign_flinker_from_sign_up(self)
    friends = self.user.friends.map(&:identifier)
    flinkers = self.class.where(uid:friends).includes(:flinker).map(&:flinker)
    FlinkerFollow.mutual_following(self.flinker, flinkers)
  end
  
  def after_sign_in
    flinker or assign_flinker or create_flinker
    update_flinker_avatar
    update_flinker_name
  end
  
  private
  
  def assign_flinker 
    return unless flinker = Flinker.where(email:user.email).first 
    self.update_attributes!(flinker_id:flinker.id)
    flinker
  end
  
  def create_flinker
    password = SecureRandom.hex(4)
    username = user.username || default_username
    flinker = Flinker.create!(email:user.email, username:username, password:password, password_confirmation:password)
    self.update_attributes!(flinker_id:flinker.id)
    FacebookFriend.create_or_update_friends(flinker) #Temp hack
    FacebookFriendSignedUpActivity.create!(self) #
    flinker
  end
  
  def default_username
    user.email[/(.*)@/, 1].to_s + Time.now.to_i.to_s
  end

end
