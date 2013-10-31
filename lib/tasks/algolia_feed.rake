namespace :shopelia do
  namespace :algolia_feed do

    require 'algolia/algolia_feed'

    desc "Download all feeds"
    task :download => :environment do
      fork { AlgoliaFeed::Tradedoubler.download(debug:1) }
      fork { AlgoliaFeed::PriceMinister.download(debug:1) }
      fork { AlgoliaFeed::Zanox.download(debug:1) }
      fork { AlgoliaFeed::Amazon.download(debug:1) }
      Process.waitall
    end

  end
end
