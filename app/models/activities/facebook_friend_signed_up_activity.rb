class FacebookFriendSignedUpActivity < Activity
  belongs_to :resource, foreign_key: :resource_id, class_name:'FlinkerAuthentication'
  
  def self.create! auth
    friendships = FacebookFriend.where(identifier:auth.uid).includes(:flinker)
    friendships.each do |friendship|
      super(flinker_id:auth.flinker_id, target_id:friendship.flinker_id, resource_id:auth.id)
    end
  end
  
end
