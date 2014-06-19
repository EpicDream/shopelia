class FacebookFriendSignedUpActivity < Activity
  belongs_to :resource, foreign_key: :resource_id, class_name:'FacebookAuthentication'
  
  def self.create! auth
    return unless auth.flinker_id
    friendships = FacebookFriend.where(flinker_id:auth.flinker_id).where('friend_flinker_id is not null').includes(:friend)
    friendships.each do |friendship|
      super(flinker_id:auth.flinker_id, target_id:friendship.friend_flinker_id, resource_id:auth.id)
      SignupNotificationWorker.perform_async(friendship.friend_flinker_id, auth.flinker_id)
    end
  end
  
end
