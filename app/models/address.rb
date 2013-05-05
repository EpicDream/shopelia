class Address < ActiveRecord::Base
  belongs_to :user
  belongs_to :country
  belongs_to :state
  belongs_to :order
  has_many :phones, :dependent => :destroy
  
  validates :user, :presence => true
  validates :country, :presence => true
  validates :address1, :presence => true
  validates :zip, :presence => true
  validates :city, :presence => true

  scope :default, where(:is_default => true)
  
  attr_accessible :user_id, :code_name, :address1, :address2, :zip, :city, :access_info, :state_id, :country_id
  attr_accessible :is_default, :company, :phones_attributes, :country_iso, :token
  attr_accessor :phones_attributes, :country_iso, :token

  before_validation do |record|
    if Address.where(:user_id => record.user_id).count == 0
      record.is_default = true 
    end
    if record.token.present?
      address = Google::PlacesApi.details record.token
      record.address1 = address["address1"]
      record.zip = address["zip"]
      record.city = address["city"]
      record.country_id = Country.find_by_iso(address["country"].upcase).id
    else
      record.country_id = Country.find_by_iso(record.country_iso.upcase).id unless record.country_iso.blank?
      record.country_id = Country.find_by_name("France").id if record.country_id.nil?
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
