class Cart < ActiveRecord::Base
  FOLLOW = 0
  CHECKOUT = 1

  KINDS = [FOLLOW, CHECKOUT]

  belongs_to :user
  has_many :cart_items, :dependent => :destroy

  validates :user_id, :presence => true, :uniqueness => { :scope => :kind }
  validates :kind, :presence => true, :inclusion => { :in => KINDS }
  validates :uuid, :presence => true, :uniqueness => true

  attr_accessible :name, :user_id, :kind

  before_validation :initialize_uuid
  before_validation :initialize_kind

  scope :checkout, where(kind:CHECKOUT)
  scope :follow, where(kind:FOLLOW)

  private

  def initialize_uuid
    self.uuid = SecureRandom.hex(16) if self.uuid.nil?
  end

  def initialize_kind
    self.kind = CHECKOUT if self.kind.nil?
  end
end
