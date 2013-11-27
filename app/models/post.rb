class Post < ActiveRecord::Base
  belongs_to :blog
  
  validates :link, presence:true, uniqueness:true
  json_attributes [:images, :products, :categories]
  
  before_create :clean_products_urls
  
  private
  
  def clean_products_urls
    self.products = self.products.inject({}) do |hash, (name, link)|
      hash.merge!({name => Linker.clean(link)})
    end.to_json
  end
end
 