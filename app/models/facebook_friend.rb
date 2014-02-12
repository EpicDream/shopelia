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
      attributes = [:identifier, :name].inject({}) {|h, attribute| h.merge(attribute => friend.send(attribute))}
      friend_flinker_id = FlinkerAuthentication.with_uid(friend.identifier).first.try(:id)
      attributes.merge!({ friend_flinker_id: friend_flinker_id, flinker_id:flinker.id })
      create(attributes)
    end
  end
  
end