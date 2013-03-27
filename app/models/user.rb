class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable, :token_authenticatable, :confirmable
  devise :recoverable, :rememberable, :trackable, :validatable

  before_save :ensure_authentication_token

  has_many :addresses
  has_many :phones

  validates :first_name, :presence => true
  validates :last_name, :presence => true

  attr_accessible :email, :password, :password_confirmation, :remember_me, :first_name, :last_name, :addresses_attributes, :phones_attributes
  attr_accessor :addresses_attributes, :phones_attributes

  after_save do |record|
    record.addresses = record.addresses_attributes
    record.phones = record.phones_attributes
  end

  def addresses= params
    (params || []).each do |address|
      address = Address.new(address.merge({:user_id => self.id}))
      self.errors.add(:base, address.errors.full_messages.join(",")) if !address.save
    end
  end

  def phones= params
    (params || []).each do |phone|
      phone = Phone.new(phone.merge({:user_id => self.id}))
      self.errors.add(:base, phone.errors.full_messages.join(",")) if !phone.save
    end
  end

end
