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
    algolia = AlgoliaFeed::FileUtils.new(debug:0, tmpdir:'/tmp')
    raw_file = algolia.retrieve_url(url)
    decoded_file = algolia.decompress_datafile(raw_file)
    assert(FileMagic.new.file(decoded_file) =~ /\AXML\s/)
    File.unlink(raw_file)
    File.unlink(decoded_file)
  end

  def test_algolia_download_ftp_and_unzip
    url = "ftp://prixing:j5Z61eg@priceminister.effiliation.com/prixing_BOOKS_TOP.xml.zip"
    algolia = AlgoliaFeed::FileUtils.new(debug: 0, tmpdir:'/tmp')
    raw_file = algolia.retrieve_url(url)
    decoded_file = algolia.decompress_datafile(raw_file)
    assert(FileMagic.new.file(decoded_file) =~ /\AXML\s/)
    File.unlink(raw_file)
    File.unlink(decoded_file)
  end

  def test_download_auth_http
    url = 'https://assoc-datafeeds-eu.amazon.com/datafeed/getFeed?filename=fr_amazon_videogames.xml.gz'
    am = AlgoliaFeed::Amazon.new(debug: 0)
    raw_file = am.filer.retrieve_url(url, '/tmp')
    decoded_file = am.filer.decompress_datafile(raw_file, '/tmp/')
    assert(FileMagic.new.file(decoded_file) =~ /\AXML\s/)
    File.unlink(raw_file)
    File.unlink(decoded_file)
  end

  def test_priceminister
    pm = AlgoliaFeed::PriceMinister.new(index_name: 'testing', tmpdir: '/tmp')
    pm.algolia.connect('testing')
    pm.process_xml("#{Rails.root}/test/data/price_minister.xml")
    sleep 1
    assert_equal(1, pm.algolia.index.search('')['hits'].size)
    record = pm.algolia.index.search('')['hits'].first
    assert(Time.now.to_i - record['timestamp'] < 5)
    assert_equal("Mode > Cosmetique-Produit-de-beaute > Cigarette Electronique (Autre)", record['category'])
    assert_equal('http://www.priceminister.com/offer/buy/206799878', record['product_url'])
    assert_difference "UrlMatcher.count", 0 do 
      url = pm.canonize('http://track.effiliation.com/servlet/effi.redir?id_compteur=ID_COMPTEUR&url=http://www.priceminister.com/offer/buy/206799878/sort1/filter10/sort1%3Ft%3DTRACKING_CODE')
      assert_equal 'http://www.priceminister.com/offer/buy/206799878', url
    end
    assert_equal(3, record['_tags'].collect{ |tag| tag if tag=~ /category:/}.compact.size)
  end

  def test_amazon_aparel
    am = AlgoliaFeed::Amazon.new(index_name: 'testing', debug:0, tmpdir: '/tmp')
    am.algolia.connect('testing')
    am.process_xml("#{Rails.root}/test/data/amazon_aparel.xml")
    sleep 1
    hits = am.algolia.index.search('')['hits']
    assert_equal(1, hits.size)
    item = hits.first
    assert_equal('http://www.amazon.fr/dp/B0047V0NJ6', item['product_url'])
    assert_equal('1', item['saturn'])
    assert_equal(Fixnum, item['price'].class)
    assert_equal(Fixnum, item['rank'].class)
  end

  def test_amazon_books
    am = AlgoliaFeed::Amazon.new(index_name: 'testing', debug: 0, tmpdir: '/tmp')
    am.algolia.connect('testing')
    am.process_xml("#{Rails.root}/test/data/amazon_books.xml")
    sleep 1
    hits = am.algolia.index.search('')['hits']
    assert_equal(1, hits.size)
    item = hits.first
    assert_equal('Philip J. Neimark', item['brand'])
    assert_equal(404, item['price'])
    assert_equal(299, item['price_shipping'])
  end

  def test_zanox
    zn = AlgoliaFeed::Zanox.new(index_name: 'testing', debug:0, tmpdir: '/tmp')
    zn.algolia.connect('testing')
    zn.process_xml("#{Rails.root}/test/data/zanox.xml")
    sleep 1
    hits = zn.algolia.index.search('')['hits']
    assert_equal(1, hits.size)
    item = hits.first
    assert_equal('1', item['saturn'])
    assert_equal('http://online.carrefour.fr/electromenager-multimedia/hp/cartouche-encre-n-342-couleur_a00000318_frfr.html', item['product_url'])
  end

  def test_tradedoubler
    td = AlgoliaFeed::Tradedoubler.new(index_name: 'testing', debug:0, tmpdir: '/tmp')
    td.algolia.connect('testing')
    td.process_xml("#{Rails.root}/test/data/tradedoubler.xml")
    sleep 1
    hits = td.algolia.index.search('')['hits']
    assert_equal(1, hits.size)
    item = hits.first
    assert_equal('monshowroom.com', item['merchant_name'])
    assert_equal('http://www.monshowroom.com/fr/zoom/un-jour-mon-prince/pochette-irisee-mini-pompon/150708', item['product_url'])
  end
end
