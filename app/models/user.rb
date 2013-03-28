class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable, :token_authenticatable, :confirmable
  devise :recoverable, :rememberable, :trackable, :validatable

  before_save :ensure_authentication_token

  has_many :addresses, :dependent => :destroy
  has_many :phones, :dependent => :destroy
  has_many :payment_cards, :dependent => :destroy
  belongs_to :nationality, :class_name => "Country"

  CIVILITY_MR = 0
  CIVILITY_MME = 1
  CIVILITY_MLLE = 2

  validates :first_name, :presence => true
  validates :last_name, :presence => true
  validates :birthdate, :presence => true
  validates :nationality, :presence => true
  validates :civility, :presence => true, :inclusion => { :in => [ CIVILITY_MR, CIVILITY_MME, CIVILITY_MLLE ] }
  validate :user_must_be_16_yo

  attr_accessible :email, :password, :password_confirmation, :remember_me, :first_name, :last_name
  attr_accessible :birthdate, :civility, :nationality_id
  attr_accessible :addresses_attributes, :phones_attributes
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
  
  def user_must_be_16_yo
    self.errors.add(:base, I18n.t('users.invalid_birthdate')) if self.birthdate.nil? || Time.now - self.birthdate < 16.years
  end
  
  def male?
    self.civility == CIVILITY_MR
  end
  
  def female?
    !self.male?
  end

end
