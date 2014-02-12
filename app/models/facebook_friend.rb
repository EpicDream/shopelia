class FacebookFriend < ActiveRecord::Base
  attr_accessible *column_names  
  
  validates :identifier, presence:true, uniqueness: { scope: :flinker_id } 
  validates :name, presence:true
  validates :flinker_id, presence:true
  
  scope :of_flinker, ->(flinker) { where(flinker_id:flinker.id) }
  scope :flinker_friends_of, ->(flinker) { of_flinker(flinker).where('friend_flinker_id is not null') }
  
  def self.create_or_update_friends flinker
    return unless auth = FlinkerAuthentication.facebook_of(flinker).first

    user = FbGraph::User.me(auth.token).fetch

    user.friends.each do |friend|
      fb_friend = FacebookFriend.new(name:friend.name, identifier:friend.identifier)
      fb_friend.picture = "#{friend.picture}?width=200&height=200&type=normal"
      fb_friend.friend_flinker_id = FlinkerAuthentication.with_uid(friend.identifier).first.try(:id)
      fb_friend.flinker_id = flinker.id
      fb_friend.save
    end
  end
  
end