class ThemeCover < Image
  DEFAULT_COVER = "default-cover.png"
  belongs_to :theme, foreign_key: :resource_id
  
  has_attached_file :picture, 
                    :styles => SIZES,
                    :convert_options => { :pico => "-quality 0", :small => "-quality 20", :large => "-quality 80" },
                    :url  => "/images/:fmd5/:style/:md5.jpg",
                    :path => ":rails_root/public/images/:fmd5/:style/:md5.jpg",
                    :preserve_files => true
  
  def self.default
    image = where(picture_file_name:DEFAULT_COVER).first
    if !image || !image.picture.exists?
      image = new
      image.picture = File.new("#{Rails.root}/app/assets/images/admin/#{DEFAULT_COVER}")
      image.save
    end
    image
  end
  
end