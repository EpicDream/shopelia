class PaymentCard < ActiveRecord::Base
  belongs_to :user
  has_many :orders
  
  validates :user, :presence => true

  attr_accessor :number, :exp_month, :exp_year, :cvv
  attr_accessible :number, :exp_month, :exp_year, :cvv, :user_id

  before_destroy :destroy_leetchi_payment_card, :if => Proc.new { |card| card.leetchi_id.present? }

  after_initialize :decrypt
  before_save :crypt

  def crypt

    raise ArgumentError, "card number is invalid: #{self.number}"   unless self.number =~ /\A[0-9]{16}\Z/
    raise ArgumentError, "card month is invalid: #{self.exp_month}" unless PaymentCard.months.include?(self.exp_month)
    raise ArgumentError, "card year is invalid: #{self.exp_year}"   unless PaymentCard.years.include?(self.exp_year)
    raise ArgumentError, "card cvv is invalid: #{self.cvv}"         unless self.cvv =~ /\A[0-9]{3}\Z/

    card_data = "#{self.number}#{self.exp_month}#{self.exp_year}#{self.cvv}"
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
  end
 
  def decrypt
    return if self.crypted.nil?
    obfuscated = $crypto.decrypt(GPGME::Data.new(Base64::decode64(self.crypted)))
    decrypted = obfuscated.to_s.gsub(/[^0-9]/, '')
    self.number = decrypted[0..15]
    self.exp_month = decrypted[16..17]
    self.exp_year = decrypted[18..21]
    self.cvv = decrypted[22..24]
  end

  def self.months
    ("01".."12").map{|i| i}
  end

  def self.years
    (Time.now.year..(Time.now.year + 10)).map{|i| i.to_s}
  end
  
  private
  
  def destroy_leetchi_payment_card
    Leetchi::Card.delete(self.leetchi_id)
  end
    
end
