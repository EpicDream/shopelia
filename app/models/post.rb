class Post < ActiveRecord::Base
  include ActionView::Helpers::TextHelper
  json_attributes [:images, :products, :categories]
  
  belongs_to :blog
  belongs_to :look
  
  validates :blog, presence:true
  validates :link, presence:true
  validate :uniqueness_domain_independant, :on => :create #same post on multiple domains
  
  before_validation :link_urls
  before_validation :set_a_title, if: -> { self.title.blank? }
  before_validation :clean_title
  before_validation :set_published_at, if: -> { self.published_at.nil? }
  after_create :convert
  
  scope :pending_processing, where("processed_at is null and look_id is not null and published_at > ?", 1.month.ago).order("published_at asc")
  scope :of_country, ->(code) { where("blogs.country = ?", code).joins(:blog) unless code.blank? }
  scope :of_blog_with_name, ->(name) { where("blogs.name = ?", name).joins(:blog) unless name.blank? }
  
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
  
  def self.create_missing_looks_for_blog blog, after=nil
    after ||= Date.parse('2013-12-01')
    posts = blog.posts.where("not exists(select id from looks where looks.id=posts.look_id) and published_at >= '#{after.to_s(:db)}'")
    posts.each do |post|
      post.update_attributes(processed_at:nil)
      post.convert
    end
  end

  private
  
  def link_urls
    self.products = self.products.inject({}) do |hash, (name, link)|
      next hash unless link = Linker.clean(link)
      hash.merge!({name => link.clean })
    end.to_json
    self.link = Linker.clean(link)
  end
  
  def set_a_title
    self.title = self.content[0...30] unless self.content.nil?
  end
  
  def set_published_at
    self.published_at = Time.now
  end
  
  def clean_title
    self.title = self.title.clean.gsub(/\s{2,}/, ' ') if self.title
  end
  
  def uniqueness_domain_independant
    uri = URI.parse(self.link)
    exist = self.blog.posts.where('link like ?', "%#{uri.path}%#{uri.query}%").count > 0
    errors.add(:link, 'already exists') if exist
  rescue URI::InvalidURIError #some url have heart and so on ascii charts ...
    true
  end
  
end