namespace :shopelia do
  namespace :algolia_feed do

    require 'algolia/algolia_feed'

    desc "Clean conforama redis contents"
    task :clean_confo => :environment do
      redis = Redis.new
      count = 0
      redis.hgetall('url_canonizer_cache').each_pair do |key,val|
        next unless val == 'http://default.pprgroup.net/conforama/'
        redis.hdel('url_canonizer_cache', key)
        count += 1
      end
      puts "Deleted #{count} entries"
    end

  end
end
