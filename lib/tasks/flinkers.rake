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
  end
end