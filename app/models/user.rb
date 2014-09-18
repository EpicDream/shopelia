class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable, :token_authenticatable, :confirmable
  devise :recoverable, :rememberable, :trackable, :validatable

  before_save :ensure_authentication_token
  before_destroy :check_absence_of_completed_orders

  has_many :addresses, :dependent => :destroy
  has_many :payment_cards, :dependent => :destroy
  has_many :merchant_accounts, :dependent => :destroy
  has_many :user_verification_failures, :dependent => :destroy
  has_many :meta_orders, :dependent => :destroy
  has_many :orders, :dependent => :destroy
  has_many :carts, :dependent => :destroy
  has_many :cart_items, :through => :carts
  has_many :devices
  has_many :events, :through => :devices
  has_many :billing_transactions
  has_many :payment_transactions, :through => :orders
  has_many :collections, :dependent => :destroy
  has_many :user_sessions
  has_many :traces

  belongs_to :nationality, :class_name => "Country"
  belongs_to :developer

  CIVILITY_MR = 0
  CIVILITY_MME = 1
  CIVILITY_MLLE = 2

  validates :email, :presence => true
  validates :civility, :inclusion => { :in => [ CIVILITY_MR, CIVILITY_MME, CIVILITY_MLLE ] }, :allow_nil => true
  validates :developer, :presence => true
  validates :first_name, length:{minimum:2}, allow_nil: true
  validates :last_name, length:{minimum:2}, allow_nil: true
  validates_format_of :first_name, :without => /\d/, message:I18n.t('activerecord.errors.no_number_allowed')
  validates_format_of :last_name, :without => /\d/, message:I18n.t('activerecord.errors.no_number_allowed')
  validates_confirmation_of :password
  validate :user_must_be_16_yo

  attr_accessible :password, :password_confirmation, :current_password
  attr_accessible :email, :remember_me, :first_name, :last_name
  attr_accessible :birthdate, :civility, :nationality_id, :ip_address, :pincode
  attr_accessible :addresses_attributes, :payment_cards_attributes
  attr_accessible :developer_id, :visitor, :tracker
  attr_accessor :addresses_attributes, :payment_cards_attributes

  before_validation :reset_test_account

  before_create :skip_confirmation_email
  after_create :process_nested_attributes
  after_update :process_nested_attributes
  after_create :leftronic_users_count
  after_destroy :leftronic_users_count
  before_update :update_mangopay_user, :if => Proc.new { |user| user.mangopay_id.present? && (first_name_changed? || last_name_changed? || birthdate_changed? || nationality_id_changed? || email_changed?) }
  after_create :notify_creation_to_admin

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
    self.last_name.blank? ? "Guest" : "#{self.first_name} #{self.last_name}"
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
  
  def can_order?
    self.addresses.count > 0 && self.payment_cards.count > 0
  end
  
  def verify data
    if data["pincode"].present?
      if data["pincode"].eql?(self.pincode) && self.pincode.present?
        self.user_verification_failures.destroy_all
        return true
      end
    elsif data["password"].present?
      if self.valid_password?(data["password"]) && self.encrypted_password.present?
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
  
  def password_required?
    super if confirmed?
  end

  def password_match?
    self.errors[:password] << "doit être rempli(e)" if password.blank?
    self.errors[:password_confirmation] << "doit être rempli(e)" if password_confirmation.blank?
    self.errors[:password_confirmation] << "ne concorde pas avec le mot de passe" if password != password_confirmation
    password == password_confirmation && !password.blank?
  end
  
  def create_mangopay_user
    return { status:"error", message:"mangopay user already created" } unless self.mangopay_id.nil?
    remote_user = MangoPay::User.create({
        'Tag' => Rails.env.test? ? "User test" : self.id.to_s,
        'Email' => self.email,
        'FirstName' => self.first_name,
        'LastName' => self.last_name,
        'Nationality' => self.nationality.nil? ? "fr" : self.nationality.iso,
        'Birthday' => self.birthdate.nil? ? 30.years.ago.to_i : self.birthdate.to_i,
        'PersonType' => 'NATURAL_PERSON',
        'CanRegisterMeanOfPayment' => true,
        'IP' => self.ip_address
    })
    if remote_user["ID"].present?
      self.update_attribute :mangopay_id, remote_user["ID"].to_i
    else
      { status:"error", message:"Impossible to create mangopay user object: #{remote_user.inspect}" }
    end
    
    self.reload
    { status:"success" }
  end    

  private
  
  def skip_confirmation_email
    self.skip_confirmation_notification!
  end
  
  def process_nested_attributes
    self.addresses = self.addresses_attributes if self.addresses_attributes.present?
    self.payment_cards = self.payment_cards_attributes if self.payment_cards_attributes.present?
  end
  
  def update_mangopay_user
    MangoPay::User.update(self.mangopay_id, {
      'Email' => self.email,
      'FirstName' => self.first_name,
      'LastName' => self.last_name,
      'Nationality' => self.nationality.nil? ? "fr" : self.nationality.iso,
      'Birthday' => self.birthdate.nil? ? 30.years.ago.to_i : self.birthdate.to_i
    })
  end

  def reset_test_account
    if self.email.eql?("test@shopelia.fr")
      user = User.find_by_email("test@shopelia.fr")
      user.destroy unless user.nil?
    end
  end

  def leftronic_users_count
    Leftronic.new.notify_users_count
  end

  def notify_creation_to_admin
    Emailer.notify_admin_user_creation(self).deliver unless self.email =~ /shopelia/ || self.visitor?
  end

  def check_absence_of_completed_orders
    if self.orders.completed.count > 0
      self.errors.add(:base, I18n.t('users.cannot_destroy'))
      false
    end
  end

end
