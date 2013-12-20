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
  end
end