class Address < ActiveRecord::Base
  belongs_to :user
  belongs_to :country
  belongs_to :state
  has_many :phones, :dependent => :destroy
  
  validates :user, :presence => true
  validates :country, :presence => true
  validates :address1, :presence => true
  validates :zip, :presence => true
  validates :city, :presence => true
  
  attr_accessible :user_id, :code_name, :address1, :address2, :zip, :city, :state_id, :country_id, :is_default, :company, :phones_attributes
  attr_accessor :phones_attributes

  before_save do |record|
    if record.is_default?
      record.user.addresses.where("id<>?", record.id || 0).update_all "is_default='f'"
    end
  end

  after_save do |record|
    record.phones = record.phones_attributes
  end
    
  def phones= params
    (params || []).each do |phone|
      phone = Phone.new(phone.merge({:user_id => self.user_id, :address_id => self.id}))
      self.errors.add(:base, phone.errors.full_messages.join(",")) if !phone.save
    end
  end
  
end
