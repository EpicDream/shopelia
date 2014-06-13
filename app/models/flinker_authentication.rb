class FlinkerAuthentication < ActiveRecord::Base
  attr_accessible :provider, :uid, :token, :picture, :email, :flinker_id, :user
  attr_accessor :user
  
  belongs_to :flinker
end
