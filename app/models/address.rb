class Address < ActiveRecord::Base
  belongs_to :user
  belongs_to :country
  belongs_to :state
  has_many :phones
  
  validates :user, :presence => true
  validates :country, :presence => true
  validates :address1, :presence => true
  validates :zip, :presence => true
  validates :city, :presence => true
  
  before_save do |record|
    if record.is_default?
      record.user.addresses.where("id<>?", record.id || 0).update_all "is_default='f'"
    end
  end
end
