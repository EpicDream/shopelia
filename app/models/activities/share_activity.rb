class ShareActivity < Activity
  ONLY = [SocialNetwork::FACEBOOK, SocialNetwork::TWITTER]
  MIN_BUILD_NUMBER = 26
  
  belongs_to :resource, foreign_key: :resource_id, class_name:'LookSharing'
  
  def self.create! look_sharing
    #WAIT NEW RELEASE
    # return unless ONLY.include?(look_sharing.social_network.name)
    # flinker = look_sharing.flinker
    # flinker.followers.each do |friend|
    #   if friend.device.try(:build) && friend.device.build > MIN_BUILD_NUMBER
    #     super(flinker_id:flinker.id, target_id:friend.id, resource_id:look_sharing.id)
    #   end
    # end
  end
  
  def look_uuid
    resource.look.uuid
  end

end
