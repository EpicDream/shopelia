class CollectionItem < ActiveRecord::Base
  belongs_to :collection
  belongs_to :product
  belongs_to :user

  validates :collection_id, :presence => true
  validates :product_id, :presence => true, :uniqueness => { :scope => :collection_id }

  attr_accessible :collection_id, :product_id, :url, :feed
  attr_accessor :url, :feed

  before_validation :check_url_validity, if:Proc.new{ |item| item.url.present? }
  before_validation :find_or_create_product, if:Proc.new{ |item| item.url.present? && item.errors.empty? }
  before_validation :build_from_feed, if:Proc.new{ |item| item.feed.present? }
  after_create :generate_event

  private

  def check_url_validity
    raise if self.url !~ /^http/
    URI.parse(self.url)
    rescue
      self.errors.add(:base, I18n.t('app.collections.add.invalid_url'))
  end
  
  def build_from_feed
    
  end

  def find_or_create_product
    self.product_id = Product.fetch(self.url).id
  end

  def generate_event
    self.product.authorize_push_channel
    EventsWorker.perform_async({
      :product_id => self.product_id,
      :action => Event::REQUEST,
      :tracker => "display-collection"
    })
  end
end