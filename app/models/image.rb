class Image < ActiveRecord::Base
  include RankedModel

  SIZES = { w640:"640x", w320:"320x", w160:"160x"}
  
  attr_accessible :url, :display_order_position
  alias_attribute :sizes, :picture_sizes
  validates :url, presence:true
  validates :picture, presence:true, on: :create
  
  has_attached_file :picture, 
                    :styles => SIZES, 
                    :url  => "/assets/images/:fmd5/:style/:md5.:extension",
                    :path => ":rails_root/public/assets/images/:fmd5/:style/:md5.:extension"
                                        
  before_create :create_files
  after_post_process { self.picture_sizes = formats.to_json }

  private
  
  def create_files
    self.picture = URI.parse self.url rescue nil
  end
  
  def formats
    SIZES.keys.inject({}) do |sizes, style|
      file = picture.queued_for_write[style]
      geometry = Paperclip::Geometry.from_file file
      sizes.merge!({style => "#{geometry.width.to_i}x#{geometry.height.to_i}"})
    end
  end
  
end
