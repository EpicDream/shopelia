class ThemeCover < Image
  belongs_to :theme, foreign_key: :resource_id
  
  has_attached_file :picture, 
                    :styles => SIZES,
                    :convert_options => { :pico => "-quality 0", :small => "-quality 20", :large => "-quality 80" },
                    :url  => "/images/:fmd5/:style/:md5.jpg",
                    :path => ":rails_root/public/images/:fmd5/:style/:md5.jpg",
                    :preserve_files => true
  
  def self.default
    image = where(picture_file_name:"fell-harmony-living.jpg").first
    if !image || !image.picture.exists?
      image = new
      image.picture = File.new("#{Rails.root}/app/assets/images/admin/fell-harmony-living.jpg")
      image.save
    end
    image
  end
  
end