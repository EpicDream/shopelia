class Post < ActiveRecord::Base
  belongs_to :blog
  
  validates :link, presence:true, uniqueness:true
  json_attributes [:images, :products, :categories]
  
end
 