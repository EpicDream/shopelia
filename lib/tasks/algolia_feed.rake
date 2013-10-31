namespace :shopelia do
  namespace :algolia_feed do

    require 'algolia/algolia_feed'

    desc "Clean, download and process Algolia feeds"
    task :run => [:clean, :download, :process, :make_prod] do
    end

    desc "Clean Algolia tmp dir"
    task :clean => :environment do
      FileUtils.rm_rf(Dir.glob("#{AlgoliaFeed::AlgoliaFeed.new.tmpdir}/*"))
    end

    desc "Download Algolia feeds"
    task :download => :environment do
      fork { AlgoliaFeed::Tradedoubler.download(debug:1) }
      fork { AlgoliaFeed::PriceMinister.download(debug:1) }
      fork { AlgoliaFeed::Zanox.download(debug:1) }
      fork { AlgoliaFeed::Amazon.download(debug:1) }
      Process.waitall
    end

    desc "Process all Algolia feeds"
    task :process => :environment do
      AlgoliaFeed::AlgoliaFeed.process_xml_directory(debug: 1)
    end

		desc "Set Algolia production index"
		task :make_prod => :environment do
			AlgoliaFeed::AlgoliaFeed.make_production
		end

  end
end

