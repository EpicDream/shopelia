class Image < ActiveRecord::Base
  attr_accessible :url
  alias_attribute :size, :picture_size
  
  has_attached_file :picture, 
                    :styles => { large:"640x", medium:"320x", small:"160x"}, 
                    :url  => "/assets/images/:fmd5/:style/:md5.:extension",
                    :path => ":rails_root/public/assets/images/:fmd5/:style/:md5.:extension"
                                        
  before_create :create_files
  after_post_process :save_original_size
  
  private
  
  def create_files
    self.picture = URI.parse self.url
  end
  
  def save_original_size
    file = picture.queued_for_write[:original]
    geometry = Paperclip::Geometry.from_file file
    self.picture_size = "#{geometry.width.to_i}x#{geometry.height.to_i}"
  end
  
end
