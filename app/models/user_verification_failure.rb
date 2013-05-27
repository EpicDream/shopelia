class UserVerificationFailure < ActiveRecord::Base
  belongs_to :user
  attr_accessible :user_id
  
  validates :user, :presence => true
  
  def self.delay user
    failures_count = UserVerificationFailure.where(user_id:user.id).count
    if failures_count >= 3
      expired_delay = Time.now.to_i - UserVerificationFailure.where(user_id:user.id).order("created_at desc").pop.created_at.to_i
      60 * (2 ** (failures_count - 3)) - expired_delay
    else
      0
    end
  end
  
end
