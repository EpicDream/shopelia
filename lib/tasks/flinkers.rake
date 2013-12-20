# -*- encoding : utf-8 -*-

namespace :shopelia do
  namespace :flinkers do
    
    desc "Generate flinkers from blogs objects"
    task :seed => :environment do
      Blog.where(flinker_id:nil).each do |blog|
        flinker = Flinker.create(name:blog.name,url:blog.url)
        blog.update_attribute :flinker_id, flinker.id
      end
    end

    desc "Import data from blog objects"
    task :populate => :environment do
      Flinker.where(is_publisher:true).each do |flinker|
        blog = Blog.find_by_flinker_id(flinker.id)
        next if blog.nil?
        flinker.avatar_url = blog.avatar_url
        flinker.country_id = Country.find_by_iso(blog.country).id
        flinker.save rescue nil
      end
    end
  end
end