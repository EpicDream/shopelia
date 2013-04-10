class Phone < ActiveRecord::Base
  belongs_to :user
  belongs_to :address

  LAND = 0
  MOBILE = 1
  
  validates :number, :presence => true
  validates :user, :presence => true
  validates :line_type, :presence => true, :inclusion => { :in => [ LAND, MOBILE ] }
  validate :land_type_must_have_address
  
  attr_accessible :user_id, :address_id, :number, :line_type
  
  scope :without_addresses, where("address_id is null")
  scope :mobile, where(:line_type => MOBILE)
  
  def land_type_must_have_address
    self.errors.add(:base, I18n.t('phones.land_line_must_have_address')) if self.line_type == LAND && self.address_id.nil?
  end
  
end
