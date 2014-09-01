require 'paper_clip_patch'

class Image < ActiveRecord::Base
  SIZES = { pico:["50x50>", :jpg], small:["320x", :jpg], large:["1200x1200>", :jpg]}
  
  attr_accessible :url, :display_order, :picture
  alias_attribute :sizes, :picture_sizes
  validates :url, presence:true, unless: ->(record) { record.class == ThemeCover } 
  validates :picture, presence:true, on: :create
  
  has_attached_file :picture, 
                    :styles => SIZES,
                    :convert_options => { :pico => "-quality 0", :small => "-quality 80", :large => "-quality 80" },
                    :url  => "/images/:fmd5/:style/:md5.jpg",
                    :path => ":rails_root/public/images/:fmd5/:style/:md5.jpg"
                                        
  before_validation :create_files
  after_post_process { self.picture_sizes = formats.to_json }

  def self.upload payload
    file = Tempfile.new('paper-clip-attachment')
    file.write(payload)
    yield file
    file.close
    file.unlink
  end
  
  def crop coordinates
    return if coordinates[:width].to_i * coordinates[:height].to_i == 0
    original = Magick::ImageList.new(self.picture.path(:original))
    original.crop!(*coordinates.values_at(:x, :y, :width, :height).map(&:to_i))
    original.write(self.picture.path(:original))
    self.picture.reprocess!
    self.save
  end
  
  def real_sizes
    original_size = Paperclip::Geometry.from_file(picture) rescue nil
    JSON.parse(picture_sizes).merge({ "original" => original_size })
  end
  
  private
  
  def create_files
    self.picture = URI.parse(URI.escape(self.url)) if self.url && self.picture_file_name.blank? rescue nil
  end
  
  def formats
    SIZES.keys.inject({}) do |sizes, style|
      file = picture.queued_for_write[style]
      geometry = Paperclip::Geometry.from_file file
      sizes.merge!({style => "#{geometry.width.to_i}x#{geometry.height.to_i}"})
    end
  end  
end
