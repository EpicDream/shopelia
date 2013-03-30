class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable, :token_authenticatable, :confirmable
  devise :recoverable, :rememberable, :trackable, :validatable

  before_save :ensure_authentication_token

  has_many :addresses, :dependent => :destroy
  has_many :phones, :dependent => :destroy
  has_many :payment_cards, :dependent => :destroy
  has_many :psp_users, :dependent => :destroy
  belongs_to :nationality, :class_name => "Country"

  CIVILITY_MR = 0
  CIVILITY_MME = 1
  CIVILITY_MLLE = 2

  validates :first_name, :presence => true
  validates :last_name, :presence => true
  validates :birthdate, :presence => true
  validates :nationality, :presence => true
  validates :civility, :presence => true, :inclusion => { :in => [ CIVILITY_MR, CIVILITY_MME, CIVILITY_MLLE ] }
  validates :ip_address, :presence => true
  validate :user_must_be_16_yo

  attr_accessible :email, :password, :password_confirmation, :remember_me, :first_name, :last_name
  attr_accessible :birthdate, :civility, :nationality_id, :ip_address
  attr_accessible :addresses_attributes, :phones_attributes
  attr_accessor :addresses_attributes, :phones_attributes

  after_save :process_nested_attributes
  after_save :create_psp_users
  before_update :update_psp_users 

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
  
  def leetchi
    self.psp_users.leetchi.first
  end
  
  private
  
  def process_nested_attributes
    self.addresses = self.addresses_attributes
    self.phones = self.phones_attributes
  end
  
  def create_psp_users
    unless Rails.env.test? && ENV["ALLOW_REMOTE_API_CALLS"].nil?  
      if self.leetchi.nil?
        wrapper = Psp::LeetchiUser.new
        if !wrapper.create(self)
          self.destroy
          self.errors.add(:base, I18n.t('leetchi.users.creation_failure', :error => wrapper.errors))
          false
        end
      end
    end
  end
  
  def update_psp_users
    unless Rails.env.test? && ENV["ALLOW_REMOTE_API_CALLS"].nil?
      if self.leetchi.present? && (first_name_changed? || last_name_changed? || birthdate_changed? || nationality_id_changed? || email_changed?)
        wrapper = Psp::LeetchiUser.new
        if !wrapper.update(self)
          self.errors.add(:base, I18n.t('leetchi.users.update_failure', :error => wrapper.errors))
          false
        end
      end
    end
  end

end
