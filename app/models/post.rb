class Post < ActiveRecord::Base
  belongs_to :blog
  
  validates :link, presence:true, uniqueness:true
  json_attributes [:images, :products, :categories]
  
  before_create :clean_products_urls
  before_create :set_status
  
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
 