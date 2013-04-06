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

  before_validation do |record|
    self.country_id = Country.find_by_name("France").id if self.country_id.nil?
    if Address.where(:user_id => record.user_id).count == 0
      record.is_default = true 
    end
  end

  before_destroy do |record|
    if record.user.addresses.where("is_default='t' and id<>?", record.id).count == 0
      default_address = record.user.addresses.where("id<>?", record.id).first
      default_address.update_attribute :is_default, true unless default_address.nil?
    end
  end

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
      if !phone.save
        self.errors.add(:base, phone.errors.full_messages.join(","))
        self.destroy
      end
    end
  end
  
end
