class Newsletter < ActiveRecord::Base
  HEADER_LOGO_URL = "http://gallery.mailchimp.com/5c443bc89621ee4e4ce814912/images/aaf3c612-4db0-4664-af20-1c2daf139c28.jpg"
  
  attr_accessible :header_img_url, :footer_img_url, :favorites_ids, :look_uuid
  attr_accessible :subject_fr, :subject_en
  
  def favorites
    Flinker.where(id:favorites_ids.split(','))
  end
  
end