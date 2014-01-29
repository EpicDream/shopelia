# -*- encoding : utf-8 -*-
include ActionView::Helpers::TextHelper

namespace :flinker do
  namespace :looks do
    
    desc "Update looks description from posts"
    task :descriptions => :environment do
      Look.where(description:nil).each do |look|
        post = Post.find_by_look_id(look.id)
        next if post.nil?
        look.description = truncate(post.content, length: 200, separator: ' ')
        look.save
      end
    end

    desc "Check images integrity"
    task :images_check => :environment do
      Image.find_each do |image|
        md5 = image.picture_fingerprint
        file = "#{Rails.root}/public/images/#{md5.first(3)}/large/#{md5}.jpg"
        next if File.exists?(file)
        begin
          image.picture = URI.parse image.url
          image.save
        rescue
        end
      end
    end
  end
end
