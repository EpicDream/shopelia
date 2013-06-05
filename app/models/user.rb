# -*- encoding : utf-8 -*-
class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable, :token_authenticatable, :confirmable
  devise :recoverable, :rememberable, :trackable, :validatable

  before_save :ensure_authentication_token

  has_many :addresses, :dependent => :destroy
  has_many :payment_cards, :dependent => :destroy
  has_many :psp_users, :dependent => :destroy
  has_many :merchant_accounts, :dependent => :destroy
  has_many :user_verification_failures, :dependent => :destroy
  has_many :orders
  belongs_to :nationality, :class_name => "Country"

  CIVILITY_MR = 0
  CIVILITY_MME = 1
  CIVILITY_MLLE = 2

  validates :first_name, :presence => true
  validates :last_name, :presence => true
  validates :civility, :inclusion => { :in => [ CIVILITY_MR, CIVILITY_MME, CIVILITY_MLLE ] }, :allow_nil => true
  validates :ip_address, :presence => true
  validates_confirmation_of :password
  validate :user_must_be_16_yo

  attr_accessible :password, :password_confirmation, :current_password
  attr_accessible :email, :remember_me, :first_name, :last_name
  attr_accessible :birthdate, :civility, :nationality_id, :ip_address, :pincode
  attr_accessible :addresses_attributes, :payment_cards_attributes
  attr_accessor :addresses_attributes, :payment_cards_attributes

  before_validation :reset_test_account

  before_create :skip_confirmation_email
  after_save :process_nested_attributes
  after_save :send_confirmation_email

  #after_save :create_psp_users
  #before_update :update_psp_users 

  def addresses= params
    (params || []).each do |address|
      address = Address.create(address.merge({:user_id => self.id}))
      if !address.persisted?
        self.errors.add(:base, address.errors.full_messages.join(","))
        self.destroy
      end
    end
  end

  def payment_cards= params
    (params || []).each do |card|
      card = PaymentCard.new(card.merge({:user_id => self.id}))
      if !card.save
        self.errors.add(:base, card.errors.full_messages.join(","))
        self.destroy
      end
    end
  end
  
  def user_must_be_16_yo
    self.errors.add(:base, I18n.t('users.invalid_birthdate')) if self.birthdate.present? && Time.now - self.birthdate < 16.years
  end
  
  def name
    "#{self.first_name} #{self.last_name}"
  end
  
  def male?
    self.civility == CIVILITY_MR
  end
  
  def female?
    !self.male?
  end
  
  def has_pincode?
    self.pincode.present? && self.pincode.length == 4
  end
  
  def has_password?
    !self.encrypted_password.blank?
  end
  
  def verify data
    if data["pincode"].present?
      if data["pincode"].eql?(self.pincode) && self.pincode.present?
        self.user_verification_failures.destroy_all
        return true
      end      
    elsif data["cc_num"].present? && data["cc_month"].present? && data["cc_year"].present?
      self.payment_cards.each do |card|
        if card.number.last(4).eql?(data["cc_num"]) && card.exp_month.to_i == data["cc_month"].to_i && card.exp_year.last(2).eql?(data["cc_year"])
          self.user_verification_failures.destroy_all
          return true
        end
      end
    end
    UserVerificationFailure.create!(user_id:self.id)
    false
  end
  
  def leetchi
    self.psp_users.leetchi.first
  end

  def password_required?
    super if confirmed?
  end

  def password_match?
    self.errors[:password] << "doit être rempli(e)" if password.blank?
    self.errors[:password_confirmation] << "doit être rempli(e)" if password_confirmation.blank?
    self.errors[:password_confirmation] << "ne concorde pas avec le mot de passe" if password != password_confirmation
    password == password_confirmation && !password.blank?
  end
  
  private
  
  def skip_confirmation_email
    @confirmation_delayed = true
    self.skip_confirmation_notification!
  end
  
  def process_nested_attributes
    if self.persisted?
      self.addresses = self.addresses_attributes
      self.payment_cards = self.payment_cards_attributes
    end
  end
  
  def send_confirmation_email
    self.send_confirmation_instructions if self.errors.count == 0 && @confirmation_delayed
  end
  
  def create_psp_users
    unless Rails.env.test? && ENV["ALLOW_REMOTE_API_CALLS"] != "1"
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
    unless Rails.env.test? && ENV["ALLOW_REMOTE_API_CALLS"] != "1"
      if self.leetchi.present? && (first_name_changed? || last_name_changed? || birthdate_changed? || nationality_id_changed? || email_changed?)
        wrapper = Psp::LeetchiUser.new
        if !wrapper.update(self)
          self.errors.add(:base, I18n.t('leetchi.users.update_failure', :error => wrapper.errors))
          false
        end
      end
    end
  end

  def reset_test_account
    if self.email.eql?("test@shopelia.fr")
      user = User.find_by_email("test@shopelia.fr")
      user.destroy unless user.nil?
    end
  end

end
