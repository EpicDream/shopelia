namespace :shopelia do
  namespace :algolia_feed do

    require 'algolia/algolia_feed'

    desc "Clean, download and process Algolia feeds"
    task :run => [:clean, :download, :process, :make_prod] do
    end

    desc "Clean Algolia"
    task :clean => :environment do
      FileUtils.rm_rf(Dir.glob("#{AlgoliaFeed::Filer.new.tmpdir}/*"))
      Merchant.update_all('products_count = NULL')
      AlgoliaFeed::Tagger.clear_redis
    end

    desc "Download Algolia feeds"
    task :download => :environment do
      fork { AlgoliaFeed::PriceMinister.new.filer.download }
      fork { AlgoliaFeed::Tradedoubler.new.filer.download }
      fork { AlgoliaFeed::Zanox.new.filer.download }
      fork { AlgoliaFeed::Amazon.new.filer.download }
      fork { AlgoliaFeed::Webgains.new.filer.download }
      fork { AlgoliaFeed::Publicidees.new.filer.download }
      Process.waitall
    end

    desc "Process all Algolia feeds"
    task :process => :environment do
      AlgoliaFeed::Filer.process_xml_directory(debug: 1)
    end

    desc "Set Algolia production index"
    task :make_prod => :environment do
      AlgoliaFeed::AlgoliaFeed.make_production
      AlgoliaFeed::Tagger.build_from_redis
    end

    desc "Start image size processing"
    task :image_processing => :environment do
      30.times { fork { ImageSizeProcessor.process_all } }
    end
  end
end
