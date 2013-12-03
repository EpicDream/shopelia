class Flinker < ActiveRecord::Base
  attr_accessible :name, :url

  has_attached_file :avatar, :url => "/images/flinker/:id/avatar.jpg", :path => "#{Rails.public_path}/images/flinker/:id/img.jpg"
end
