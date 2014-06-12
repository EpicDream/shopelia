require 'instagram/instagram_connect'

class InstagramUser < ActiveRecord::Base
  attr_accessible :access_token, :flinker_id, :instagram_id
  
  has_and_belongs_to_many(:friendships,
      class_name: 'InstagramUser', 
      join_table: :instagram_friendships,
      foreign_key: :instagram_user_id,
      association_foreign_key: :instagram_target_id)
  
  validates :flinker_id, presence:true, uniqueness:true
      
  def self.init flinker, instagram_access_token
    client = InstagramConnect.new(instagram_access_token)
    user = create(flinker_id:flinker.id, instagram_id:client.me.id, access_token:instagram_access_token)
    user.friends(refresh: true)
    user
  rescue => e
    Rails.logger.error("[InstagramUser][init]#{e.inspect}\n#{e.backtrace.join("\n")}")
    nil
  end
  
  def friends refresh: false
    return friendships unless refresh
    client = InstagramConnect.new(self.access_token)
    friends = InstagramUser.where(instagram_id: client.followings.map {|user| user.id.to_i })
    self.friendships.destroy_all
    self.friendships << friends
  end
end