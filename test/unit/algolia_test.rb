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

  def test_download_auth_http
    url = 'https://httpwwwprixin-21:fjisnrsd48@assoc-datafeeds-eu.amazon.com/datafeed/getFeed?filename=fr_amazon_videogames.xml.gz'
    algolia = AlgoliaFeed::AlgoliaFeed.new
    raw_file = algolia.retrieve_url(url)
    decoded_file = algolia.decompress_datafile(raw_file)
    assert(FileMagic.new.file(decoded_file) =~ /\AXML\s/)
    File.unlink(raw_file)
    File.unlink(decoded_file)
  end

  def test_priceminister
    algolia = AlgoliaFeed::PriceMinister.new(index_name: 'testing')
    algolia.connect('testing')
    algolia.process_xml("#{Rails.root}/test/data/price_minister.xml")
    sleep 1
    assert_equal(1, algolia.index.search('')['hits'].size)
    record = algolia.index.search('')['hits'].first
    assert(Time.now.to_i - record['timestamp'] < 5)
    assert_equal("Mode > Cosmetique-Produit-de-beaute > Cigarette Electronique (Autre)", record['category'])
    assert_equal('http://www.priceminister.com/offer/buy/206799878', record['product_url'])
    assert_difference "UrlMatcher.count", 0 do 
      url = algolia.canonize('http://track.effiliation.com/servlet/effi.redir?id_compteur=ID_COMPTEUR&url=http://www.priceminister.com/offer/buy/206799878/sort1/filter10/sort1%3Ft%3DTRACKING_CODE')
      assert_equal 'http://www.priceminister.com/offer/buy/206799878', url
    end
    assert_equal(3, record['_tags'].collect{ |tag| tag if tag=~ /category:/}.compact.size)
    algolia.index.delete
  end

  def test_amazon
    algolia = AlgoliaFeed::Amazon.new(index_name: 'testing')
    algolia.connect('testing')
    algolia.process_xml("#{Rails.root}/test/data/amazon_aparel.xml")
    sleep 1
    hits = algolia.index.search('')['hits']
    assert_equal(1, hits.size)
    item = hits.first
    assert_equal('http://www.amazon.fr/dp/B0047V0NJ6', item['product_url'])
    assert_equal('1', item['saturn'])
  end

end
