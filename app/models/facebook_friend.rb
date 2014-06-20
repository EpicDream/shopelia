class FacebookFriend < ActiveRecord::Base
  attr_accessible *column_names  
  
  belongs_to :flinker
  belongs_to :friend, foreign_key: :friend_flinker_id, class_name:'Flinker' #fb friend who is flinker
  
  validates :identifier, presence:true, uniqueness: { scope: :flinker_id } 
  validates :name, presence:true
  validates :flinker_id, presence:true
  
  scope :of_flinker, ->(flinker) { where(flinker_id:flinker.id, sex:"female") }
  scope :flinkers, -> { where('friend_flinker_id is not null') }
  scope :not_flinkers, -> { where('friend_flinker_id is null') }
  
  def self.create_or_update_friends flinker
    return unless auth = FacebookAuthentication.facebook_of(flinker).first

    query = "SELECT uid, name, username, sex, devices FROM user WHERE uid in (SELECT uid2 FROM friend WHERE uid1='#{auth.uid}')"
    friends = FbGraph::Query.new(query).fetch(access_token: auth.token)
    friends.each do |friend|
      next unless has_ios_device?(friend)
      fb_friend = where(identifier:friend["uid"].to_s).first || new(name:friend["name"], identifier:friend["uid"])
      fb_friend.picture = "http://graph.facebook.com/#{friend['uid']}/picture?width=200&height=200&type=normal"
      fb_friend.friend_flinker_id = FacebookAuthentication.with_uid(friend["uid"].to_s).first.try(:flinker_id)
      fb_friend.username = friend["username"]
      fb_friend.flinker_id = flinker.id
      fb_friend.sex = friend["sex"]
      fb_friend.save
    end
  end
  
  def self.has_ios_device? friend
    friend["devices"].any? && friend["devices"].detect { |device| device["os"] =~ /ios/i }
  end
  
  def self.assign_flinker_from_sign_up flinker_authentication
    self.where(identifier:flinker_authentication.uid).each { |instance|
      instance.update_attributes!(friend_flinker_id: flinker_authentication.flinker_id)
    }
  end
  
end