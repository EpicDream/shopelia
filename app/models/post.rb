include ActionView::Helpers::TextHelper

class Post < ActiveRecord::Base
  belongs_to :blog
  belongs_to :look
  
  validates :blog, presence:true
  validates :link, presence:true, uniqueness:true
  json_attributes [:images, :products, :categories]
  
  before_validation :link_urls
  before_validation :set_a_title, if: -> { self.title.blank? }
  before_validation :set_published_at, if: -> { self.published_at.nil? }
  after_create :convert
  
  scope :pending_processing, where("processed_at is null and look_id is not null and published_at > ?", 1.month.ago).order("published_at desc")

  def convert
    if self.images.count > 1 && self.look.nil?
      look = Look.create!(
        name:self.title,
        published_at:self.published_at,
        url:self.link,
        flinker_id:self.blog.flinker_id,
        description:truncate(self.content, length: 200, separator: ' '))
      self.update_attribute :look_id, look.id
      developer = Developer.find_by_name!("Flink")
      self.products.each do |product|
        text, url = product.to_a.flatten
        if Merchant.from_url(url, false).present?
          p = Product.fetch(url)
          Event.create(product_id:p.id,developer_id:developer.id,tracker:'look-converter',action:Event::REQUEST)
          LookProduct.create(product_id:p.id, look_id:self.look_id)
        end
      end
      self.images.each do |url|
        self.look.look_images << LookImage.create(url:url)
      end
    end
  end

  def links
    links = []
    self.products.each do |product|
      text, url = product.to_a.flatten
      links << { text:(text || "Default"), url:url } if Merchant.from_url(url, false).nil?
    end
    links
  end

  private
  
  def link_urls
    self.products = self.products.inject({}) do |hash, (name, link)|
      hash.merge!({name => Linker.clean(link).clean })
    end.to_json
    self.link = Linker.clean(link)
  end
  
  def set_a_title
    self.title = self.content[0...30]
  end
  
  def set_published_at
    self.published_at = Time.now
  end
end