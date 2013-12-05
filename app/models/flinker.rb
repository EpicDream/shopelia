class Flinker < ActiveRecord::Base
  has_many :looks

  attr_accessible :name, :url, :is_publisher

  has_attached_file :avatar, :url => "/images/flinker/:id/avatar.jpg", :path => "#{Rails.public_path}/images/flinker/:id/img.jpg"
end
