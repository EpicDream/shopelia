class Message < ActiveRecord::Base
  belongs_to :device

  before_validation :ensure_content
  before_validation :ensure_device_pushable
  before_save :serialize_data
  after_create :set_pending_answer
  after_update :set_pending_answer_for_card
  after_update :notify_read_at
  after_create :notify

  serialize :data, Array

  validates :device, :presence => true

  attr_accessible :content, :data, :device_id, :read_at, :products_urls, :from_admin
  attr_accessible :collection_uuid, :gift_gender, :gift_age, :gift_budget, :gift_card
  attr_accessor :products_urls, :gift_card

  def build_push_data
    self.data.map do |url|
      product = Product.fetch(url)
      { product_url:product.url,
        name:product.name,
        image_url:product.image_url,
        price:product.product_versions.first.price }
    end
  end

  def self.from_user
    where(from_admin: false)
  end

  def as_push
    hash = {
      type:'Georges',
      message:self.content,
      message_id:self.id,
      georges:self.from_admin ? 1 : 0,
      timestamp:self.created_at.to_i
    }    
    if self.data.present?
      hash = hash.merge({
        products:self.build_push_data
      })
    elsif self.gift_card.to_i > 0
      hash = hash.merge({
        survey:'gift'
      })
    elsif self.collection_uuid.present?
      collection = Collection.find_by_uuid(self.collection_uuid)
      product = collection.collection_items.order(:created_at).first.product
      if collection.collection_items.count > 3
        hash = hash.merge({
          collection:{
            collection_uuid:self.collection_uuid,
            collection_size:collection.collection_items.count,
            image_url:product.image_url,
            image_size:product.image_size
          }
        })
      else
        hash = hash.merge({
          products:collection.collection_items.map { |item|
            { product_url:item.product.url,
              name:item.product.name,
              image_url:item.product.image_url,
              price:item.product.product_versions.first.price }
          }
        })
      end
    end
    hash
  end

  private

  def set_pending_answer
    self.device.update_attributes(pending_answer:!self.from_admin?)
  end

  def set_pending_answer_for_card
    if self.gift_budget_changed?
      self.device.update_attributes(pending_answer:true)
      Pusher.trigger("georges-room-#{self.device.id}", "card_gift", {
        id:self.id,
        gift_gender:self.gift_gender,
        gift_age:self.gift_age,
        gift_budget:self.gift_budget
      })
    end
  end

  def notify_read_at
    Pusher.trigger("georges-room-#{self.device.id}", "read", {id:self.id}) if self.read_at_changed?
  end

  def serialize_data
    if self.products_urls.present?
      self.data =  self.products_urls.split(/\r?\n/).compact
      developer = Developer.find_by_name("Shopelia")
      self.data.each do |url|
        EventsWorker.perform_async({
          :url => url.unaccent,
          :developer_id => developer.id,
          :action => Event::REQUEST,
          :tracker => "georges",
          :device_id => self.device.id
        })
      end
    end
  end

  def ensure_content
    self.errors.add(:base, I18n.t('messages.errors.empty')) unless content.present? || products_urls.present?
  end

  def ensure_device_pushable
    self.errors.add(:base, I18n.t('messages.errors.device_not_pushable')) unless self.device.push_token.present?
  end

  def notify
    if self.from_admin?
      Push.send_message(self)
    else
      Emailer.notify_admin_new_message_to_george(self).deliver
      Leftronic.new.push_tts("Georges, " + self.content) unless self.content.blank?
    end
    Pusher.trigger("georges-room-#{self.device.id}", "new", {id:self.id})
  end
end
