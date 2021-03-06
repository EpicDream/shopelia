class PaymentCard < ActiveRecord::Base
  belongs_to :user
  has_many :meta_orders
 
  validates :user, :presence => true
  validate  :validate_number
  validates :exp_month, numericality: { only_integer: true,  greater_than: 0, less_than: 13 }, length: { is:2 }
  validates :exp_year, numericality: { only_integer: true, greater_than_or_equal_to: Time.now.year, less_than_or_equal_to: Time.now.year + 10 }, length: { is:4 }
  validates :cvv, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 999  }, length: { is:3 }

  def validate_number
    errors.add(:number, "is invalid") unless CreditCardValidator::Validator.valid?(self.number || '')
  end

  after_initialize :decrypt
  after_save :decrypt
  before_save :crypt

  before_destroy :destroy_associated_orders
  before_destroy :destroy_mangopay_payment_card, :if => Proc.new { |card| card.mangopay_id.present? }

  def self.months
    ("01".."12").map{|i| i}
  end

  def self.years
    (Time.now.year..(Time.now.year + 10)).map{|i| i.to_s}
  end

    

  def create_mangopay_card
    return { status:"error", message:"mangopay card already created" } unless self.mangopay_id.nil?
    
    if self.user.mangopay_id.nil?
      result = self.user.create_mangopay_user 
      return result if result[:status] == "error"
    end

    remote_card = MangoPay::Card.create({
      'Tag' => self.id.to_s,
      'OwnerID' => self.user.mangopay_id,
      'ReturnURL' => 'https://www.shopelia.fr/null'
    })
    if remote_card['ID'].present?
      begin
        PaylineDriver.inject(self, remote_card["RedirectURL"]) 
      rescue PaylineDriver::DriverError => e
        return { status:"error", message:"Impossible to inject payment card in Payline form: #{e.inspect}" }
      end
    else
      return { status:"error", message:"Impossible to create mangopay payment card object: #{remote_card.inspect}" }
    end
      
    # Wait for card approval
    attempts = 0
    begin
      sleep 1 if attempts > 0
      check_card = MangoPay::Card.details(remote_card['ID'])
      attempts += 1
    end while not (check_card["CardNumber"] || "").length == 16 || attempts > 30
  
    if (check_card["CardNumber"] || "").length == 16
      self.update_attribute :mangopay_id, remote_card["ID"].to_i
    else
      MangoPay::Card.delete(remote_card["ID"])
      return { status:"error", message:"MangoPay card injection from Payline timed out: #{check_card.inspect}" }
    end

    self.reload
    { status: "success" }
  end
  
  private

  def crypt

    card_data = "#{self.number}#{self.exp_month}#{self.exp_year}#{self.cvv}"
    unless card_data =~ /\A\d{25}\Z/
      id = self.id.nil? ? 'nil - new card' : self.id
      raise ArgumentError, "Will not save: card data is invalid for PaymentCard ID #{id}"
    end

    obfuscated = ''
    card_data.split(//).each do |c|
      filler_size = Random.rand(4) + 1
      obfuscated += c
      i = 0
      while i < filler_size do
        obfuscated = obfuscated + (('a'..'z').to_a | ('A'..'Z').to_a)[Random.rand(52)]
        i += 1
      end
    end
    self.crypted = Base64::encode64($crypto.encrypt(obfuscated, :recipients => "gpg-#{Rails.env}@shopelia.com").to_s)
    self.number = "#{self.number[0]}XXXXXXXXXXX#{self.number[12..15]}"
    self.cvv = 'XXX'
  end
 
  def decrypt
    return if self.crypted.nil?
    obfuscated = $crypto.decrypt(GPGME::Data.new(Base64::decode64(self.crypted)))
    decrypted = obfuscated.to_s.gsub(/[^0-9]/, '')
    raise ArgumentError, "Card data is invalid for PaymentCard ID #{self.id}" unless decrypted =~ /\A[0-9]{25}\Z/
    raise ArgumentError, "Number does not match crypted value for PaymentCard ID #{self.id}" unless self.number[0] == decrypted[0]
    raise ArgumentError, "Number does not match crypted value for PaymentCard ID #{self.id}" unless self.number[12..15] == decrypted[12..15]
    raise ArgumentError, "Exp month does not match crypted value for PaymentCard ID #{self.id}"   unless self.exp_month == decrypted[16..17]
    raise ArgumentError, "Exp year does not match crypted value for PaymentCard ID #{self.id}"    unless self.exp_year == decrypted[18..21]

    self.number = decrypted[0..15]
    self.cvv = decrypted[22..24]

  rescue SecurityError
  end
  
  def destroy_mangopay_payment_card
    MangoPay::Card.delete(self.mangopay_id)
  end

  def destroy_associated_orders
    MetaOrder.where(payment_card_id:self.id).each do |meta|
      meta.orders.running.each do |order|
        order.reject "payment_card_destroyed"
      end
    end
  end
  
end
