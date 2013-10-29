namespace :shopelia do
  namespace :algolia_feed do

    require 'algolia/algolia_feed'
    
    desc "Process all Algolia feeds"
    task :run => :environment do
      AlgoliaFeed::Cdiscount.run
      AlgoliaFeed::PriceMinister.run
      AlgoliaFeed::Zanox.run
      AlgoliaFeed::Amazon.run
#      AlgoliaFeed::AlgoliaFeed.make_production
    end
  end
end
