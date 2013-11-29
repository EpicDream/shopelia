class Post < ActiveRecord::Base
  belongs_to :blog
  belongs_to :look
  
  validates :blog, presence:true
  validates :link, presence:true, uniqueness:true
  json_attributes [:images, :products, :categories]
  
  before_create :clean_products_urls
  before_create :set_status
  
  def generate_look
    if self.look.nil?
      look = Look.create!(name:self.title,published_at:self.published_at,url:self.link,flinker_id:self.blog.flinker_id)
      self.update_attribute :look_id, look.id
    end
    self.look
  end

  def convert
    developer = Developer.find_by_name("Flink")
    products = []
    links = []
    self.products.each do |product|
      text, url = product.to_a.flatten
      merchant = Merchant.find_by_domain(Utils.extract_domain(url))
      if merchant.present?
        p = Product.fetch(url)
        Event.create(product_id:p.id,developer_id:developer.id,tracker:'look-converter',action:Event::REQUEST)
        products << p
      else
        links << { text:text, url:url }
      end
    end
    [products, links]
  end

  private
  
  def set_status
    self.status = 'pending'
  end

  def clean_products_urls
    self.products = self.products.inject({}) do |hash, (name, link)|
      hash.merge!({name => Linker.clean(link)})
    end.to_json
  end
end
 