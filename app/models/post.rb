class Post < ActiveRecord::Base
  belongs_to :blog
  validates :link, presence:true, uniqueness:true
  
  def images
    JSON.parse(read_attribute(:images))
  end
  
  def products
    JSON.parse(read_attribute(:products))
  end
  
  def categories
    JSON.parse(read_attribute(:categories))
  end
  
end
