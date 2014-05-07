namespace :flink do
  namespace :flinkers do
    
    desc "Reindex algolia flinkers index, by batch of 10000"
    task :algolia_reindex => :environment do
      Flinker.reindex!(10000)
    end
    
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
    
    desc "Bootstrap flinkers timezone from mixpanel csv"
    task :bootstrap_timezones => :environment do
      CSV.foreach("#{Rails.root}/db/timezones.csv") do |row|
        next if row[1].blank?
        next unless flinker = Flinker.find_by_id(row[0])
        flinker.update_attributes(timezone:row[1])
      end
    end
  end
end