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

    desc "Import avatars from blog objects"
    task :avatars => :environment do
      Flinker.where("avatar_file_name is null").each do |flinker|
        blog = Blog.find_by_flinker_id(flinker.id)
        next if blog.nil?
        flinker.avatar = URI.parse blog.avatar_url
        flinker.save
      end
    end
  end
end