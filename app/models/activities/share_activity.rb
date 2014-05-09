class ShareActivity < Activity
  ONLY = [SocialNetwork::FACEBOOK, SocialNetwork::TWITTER]
  
  belongs_to :resource, foreign_key: :resource_id, class_name:'LookSharing'
  
  def self.create! look_sharing
    #WAIT NEW RELEASE
    # return unless ONLY.include?(look_sharing.social_network.name)
    # flinker = look_sharing.flinker
    # flinker.followers.each do |friend|
    #   super(flinker_id:flinker.id, target_id:friend.id, resource_id:look_sharing.id)
    # end
  end
  
  def look_uuid
    resource.look.uuid
  end

end
