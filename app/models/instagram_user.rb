require 'social/instagram/instagram_connect'

class InstagramUser < ActiveRecord::Base
  attr_accessible :access_token, :flinker_id, :instagram_id, :full_name, :username
  
  belongs_to :flinker
  has_and_belongs_to_many(:friendships,
      class_name: 'InstagramUser', 
      join_table: :instagram_friendships,
      foreign_key: :instagram_user_id,
      association_foreign_key: :instagram_target_id)
  
  validates :flinker_id, presence:true, uniqueness:true
   
  scope :friendships_of, ->(user) { 
    where(flinker_id: user.friends.map(&:flinker_id))
  }
  
  def self.init flinker, token
    client = InstagramConnect.new(token)
    me = client.me
    user = find_or_create_by_flinker_id(flinker_id:flinker.id)
    user.update_attributes(access_token: token, instagram_id:me.id.to_s, full_name:me.full_name, username:me.username)
    user.friends(refresh: true)
    user
  rescue => e
    Rails.logger.error("[InstagramUser][init]#{e.inspect}\n#{e.backtrace.join("\n")}")
    nil
  end
  
  def friends refresh: false
    return friendships unless refresh
    client = InstagramConnect.new(self.access_token)
    friends = InstagramUser.where(instagram_id: client.followings.map {|user| user.id.to_s })
    self.friendships.destroy_all
    self.friendships << friends
  end
end