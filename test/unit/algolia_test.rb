# -*- encoding : utf-8 -*-
require 'test_helper'
require 'filemagic'
require 'algolia/algolia_feed'

class AlgoliaTest < ActiveSupport::TestCase

  setup do
    if Algolia.list_indexes['items'].collect{ |i| i['name'] }.include?('testing')
      algolia = AlgoliaFeed::AlgoliaFeed.new
      algolia.connect('testing')
      algolia.index.delete
    end
  end

  def test_algolia_download_http_and_gunzip
    url = "http://productdata.zanox.com/exportservice/v1/rest/19024603C1357169475.xml?ticket=F03A5E4E67A27FD5925A570370AD7885&gZipCompress=yes"
    algolia = AlgoliaFeed::AlgoliaFeed.new
    raw_file = algolia.retrieve_url(url)
    decoded_file = algolia.decompress_datafile(raw_file)
    assert(FileMagic.new.file(decoded_file) =~ /\AXML\s/)
    File.unlink(raw_file)
    File.unlink(decoded_file)
  end

  def test_algolia_download_ftp_and_unzip
    url = "ftp://prixing:j5Z61eg@priceminister.effiliation.com/prixing_BOOKS_TOP.xml.zip"
    algolia = AlgoliaFeed::AlgoliaFeed.new
    raw_file = algolia.retrieve_url(url)
    decoded_file = algolia.decompress_datafile(raw_file)
    assert(FileMagic.new.file(decoded_file) =~ /\AXML\s/)
    File.unlink(raw_file)
    File.unlink(decoded_file)
  end

  def test_priceminister_complete_file
    algolia = AlgoliaFeed::PriceMinister.new(
      urls: ['ftp://prixing:j5Z61eg@priceminister.effiliation.com/prixing_MUSIC_TOP.xml.zip'],
      index_name: 'testing'
    )
    algolia.run
    sleep 1
    madonna_cds = algolia.index.search('Madonna Ghv2')
    madonna_cd = madonna_cds['hits'].first
    found_merchantname = false
    madonna_cd['_tags'].each do |tag|
      if tag =~ /merchant_name/
        found_merchantname = true
        assert_equal('merchant_name:Price Minister', tag)
      end
    end
    assert(found_merchantname)
    assert_equal('1', madonna_cd['saturn'])
    assert_equal('http://www.priceminister.com', madonna_cd['merchant']['url'])
    algolia.index.delete
  end

  def test_sex_keywords
    algolia = AlgoliaFeed::PriceMinister.new(index_name: 'testing')
    algolia.connect('testing')
    algolia.process_xml("#{Rails.root}/test/data/price_miniter_sex.xml")
    sleep 1
    assert_equal(1, algolia.index.search('')['hits'].size)
    algolia.index.delete
  end

  def test_misc_data
    algolia = AlgoliaFeed::PriceMinister.new(index_name: 'testing')
    algolia.connect('testing')
    algolia.process_xml("#{Rails.root}/test/data/price_miniter_sex.xml")
    sleep 1
    record = algolia.index.search('')['hits'].first
    assert(Time.now.to_i - record['timestamp'] < 5)
    assert_equal("Mode > Cosmetique-Produit-de-beaute > Cigarette Electronique (Autre)", record['category'])
    assert_equal(3, record['_tags'].collect{ |tag| tag if tag=~ /category:/}.compact.size)
    algolia.index.delete
  end

end
