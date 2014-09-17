require 'social/twitter/twitter_connect'

class TwitterUser < ActiveRecord::Base
  attr_accessible :access_token, :access_token_secret, :flinker_id, :twitter_id, :username
  
  belongs_to :flinker
  has_and_belongs_to_many(:friendships,
      class_name: 'TwitterUser', 
      join_table: :twitter_friendships,
      foreign_key: :twitter_user_id,
      association_foreign_key: :twitter_target_id)
  
  validates :flinker_id, presence:true, uniqueness:true
   
  scope :friendships_of, ->(user) { 
    where(flinker_id: user.friends.map(&:flinker_id))
  }
  
  def self.init flinker, token, token_secret
    client = TwitterConnect.new(token, token_secret)
    me = client.me
    user = find_or_create_by_flinker_id(flinker_id: flinker.id)
    user.update_attributes(access_token: token, access_token_secret: token_secret, twitter_id: me.id.to_s, username: me.screen_name)
    user.friends(refresh: true)
    user
  rescue => e
    Rails.logger.error("[TwitterUser][init]#{e.inspect}\n#{e.backtrace.join("\n")}")
    nil
  end
  
  def friends refresh: false
    return friendships unless refresh
    client = TwitterConnect.new(self.access_token, self.access_token_secret)
    friends = TwitterUser.where(twitter_id: client.friends_ids)
    self.friendships.destroy_all
    self.friendships << friends
  end
end