class FacebookFriend < ActiveRecord::Base
  attr_accessible *column_names  
  
  belongs_to :flinker
  belongs_to :friend, foreign_key: :friend_flinker_id, class_name:'Flinker' #fb friend who is flinker
  
  validates :identifier, presence:true, uniqueness: { scope: :flinker_id } 
  validates :name, presence:true
  validates :flinker_id, presence:true
  
  scope :of_flinker, ->(flinker) { where(flinker_id:flinker.id) }
  scope :flinkers, -> { where('friend_flinker_id is not null') }
  scope :not_flinkers, -> { where('friend_flinker_id is null') }
  
  def self.create_or_update_friends flinker
    return unless auth = FlinkerAuthentication.facebook_of(flinker).first

    query = "SELECT uid, name, username FROM user WHERE uid in (SELECT uid2 FROM friend WHERE uid1='#{auth.uid}')"
    friends = FbGraph::Query.new(query).fetch(access_token: auth.token)

    friends.each do |friend|
      fb_friend = FacebookFriend.new(name:friend["name"], identifier:friend["uid"])
      fb_friend.picture = "http://graph.facebook.com/#{friend['uid']}/picture?width=200&height=200&type=normal"
      fb_friend.friend_flinker_id = FlinkerAuthentication.with_uid(friend["uid"]).first.try(:id)
      fb_friend.username = friend["username"]
      fb_friend.flinker_id = flinker.id
      fb_friend.save
    end
  end
  
end