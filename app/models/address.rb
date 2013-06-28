class Address < ActiveRecord::Base
  belongs_to :user
  belongs_to :country
  belongs_to :state
  belongs_to :order
  
  validates :user, :presence => true
  validates :country_id, :presence => true
  validates :address1, :presence => true
  validates :zip, :presence => true
  validates :city, :presence => true
  validates :first_name, :presence => true
  validates :last_name, :presence => true
  validates :phone, :presence => true

  scope :default, where(:is_default => true)
  
  attr_accessible :user_id, :code_name, :address1, :address2, :zip, :city, :access_info, :state_id, :country_id
  attr_accessible :is_default, :company, :country_iso, :reference, :first_name, :last_name, :phone
  attr_accessor :country_iso, :reference

  before_validation do |record|
    if Address.where(:user_id => record.user_id).count == 0
      record.is_default = true 
    end
    if record.reference.present?
      address = Google::PlacesApi.details record.reference
      record.address1 = address["address1"]
      record.zip = address["zip"]
      record.city = address["city"]
      record.country_id = Country.find_by_iso(address["country"].upcase).id
    else
      record.country_id = Country.find_by_iso(record.country_iso.upcase).id unless record.country_iso.blank?
      record.country_id = Country.find_by_name("France").id if record.country_id.nil?
    end
    record.first_name = record.user.first_name if record.first_name.blank?
    record.last_name = record.user.last_name if record.last_name.blank?
  end

  before_destroy do |record|
    if record.user.addresses.where("is_default='t' and id<>?", record.id).count == 0
      default_address = record.user.addresses.where("id<>?", record.id).first
      default_address.update_attribute :is_default, true unless default_address.nil?
    end
    Order.running.where(address_id:record.id).each do |order|
      order.reject "address_destroyed"
    end
  end

  before_save do |record|
    if record.is_default?
      record.user.addresses.where("id<>?", record.id || 0).update_all "is_default='f'"
    end
  end
  
end
