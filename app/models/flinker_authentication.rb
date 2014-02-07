class FlinkerAuthentication < ActiveRecord::Base
  FACEBOOK = "facebook"
  
  attr_accessible :provider, :uid, :token, :picture, :email, :flinker_id
  
  belongs_to :flinker
  
  scope :facebook_of, ->(flinker) { where(flinker_id:flinker.id, provider:FACEBOOK).first }

  def self.facebook token
    user = FbGraph::User.me(token).fetch
    auth = where(uid:user.identifier).first || create!(uid:user.identifier, email:user.email, picture:user.picture, provider:FACEBOOK)
    flinker = auth.flinker || assign_flinker(user, auth) || create_flinker_from(user, auth)
    after_signed(auth, token, user)
    flinker
  end
  
  def refresh_token! token
    update_attributes!(token:token)
  end
  
  def update_flinker_avatar
    self.reload
    return unless flinker.avatar.url =~ /missing/
    flinker.avatar_url = self.picture
    flinker.save!
  end

  private
  
  def self.after_signed auth, token, user #in background task
    auth.refresh_token! token
    auth.update_flinker_avatar
    #TODO:move elsewhere module
    friends = user.friends.map(&:identifier)
    flinkers = self.where(uid:friends).includes(:flinker).map(&:flinker)
    flinkers.each do |flinker|
      FlinkerFollow.create!(follow_id:flinker.id, flinker_id:auth.flinker.id)
    end
  end
  
  def self.assign_flinker user, auth
    return unless flinker = Flinker.where(email:user.email).first 
    auth.update_attributes!(flinker_id:flinker.id)
    flinker
  end
  
  def self.create_flinker_from user, auth
    password = SecureRandom.hex(4)
    flinker = Flinker.create!(email:user.email, username:user.username, password:password, password_confirmation:password)
    auth.update_attributes!(flinker_id:flinker.id)
    flinker
  end

end
