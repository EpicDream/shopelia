namespace :shopelia do
  namespace :algolia_feed do

    require 'algolia/algolia_feed'

    desc "Clean, download and process Algolia feeds"
    task :run => [:clean, :download, :process, :make_prod] do
    end

    desc "Clean Algolia tmp dir"
    task :clean => :environment do
      FileUtils.rm_rf(Dir.glob("#{AlgoliaFeed::FileUtils.new.tmpdir}/*"))
    end

    desc "Download Algolia feeds"
    task :download => :environment do
      fork { AlgoliaFeed::PriceMinister.new(debug:1).filer.download }
      fork { AlgoliaFeed::Tradedoubler.new(debug:1).filer.download }
      fork { AlgoliaFeed::Zanox.new(debug:1).filer.download }
      fork { AlgoliaFeed::Amazon.new(debug:1).filer.download }
      Process.waitall
    end

    desc "Process all Algolia feeds"
    task :process => :environment do
      AlgoliaFeed::FileUtils.process_xml_directory(debug: 1)
    end

		desc "Set Algolia production index"
		task :make_prod => :environment do
			AlgoliaFeed::AlgoliaFeed.make_production
		end

    desc "Start image size processing"
    task :image_processing => :environment do
      30.times { fork { ImageSizeProcessor.process_all } }
    end
  end
end
