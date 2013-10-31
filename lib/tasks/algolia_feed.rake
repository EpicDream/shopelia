namespace :shopelia do
  namespace :algolia_feed do

    require 'algolia/algolia_feed'

    desc "Download all feeds"
    task :download => :environment do
      fork AlgoliaFeed::Tradedoubler.download
      fork AlgoliaFeed::PriceMinister.download
      fork AlgoliaFeed::Zanox.download
      fork AlgoliaFeed::Amazon.download
      Process.waitall
    end

  end
end
