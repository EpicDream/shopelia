class Post < ActiveRecord::Base
  belongs_to :blog
  belongs_to :look
  
  validates :blog, presence:true
  validates :link, presence:true, uniqueness:true
  json_attributes [:images, :products, :categories]
  
  before_create :link_urls
  after_create :convert

  def generate_look
    if self.look.nil?
      look = Look.create!(name:self.title,published_at:self.published_at,url:self.link,flinker_id:self.blog.flinker_id)
      self.update_attribute :look_id, look.id
    end
    self.look
  end

  def convert
    self.generate_look
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

  def links
    links = []
    self.products.each do |product|
      text, url = product.to_a.flatten
      links << { text:text, url:url } if Merchant.from_url(url, false).nil?
    end
    links
  end

  private
  
  def link_urls
    self.products = self.products.inject({}) do |hash, (name, link)|
      hash.merge!({name => Linker.clean(link)})
    end.to_json
    self.link = Linker.clean(link)
  end
end