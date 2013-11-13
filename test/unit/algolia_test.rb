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
    AlgoliaFeed::Tagger.clear_redis
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
    assert_equal('1', Redis.new.hget(AlgoliaFeed::Tagger::TAGS_HASH, 'category:Mode'))
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
    assert(item['_tags'].include?('category:Occult'))
    assert_equal('Livres anglais et étrangers/Subjects/Religion & Spirituality/Occult/Spiritualism', item['category'])
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

  def test_broken_zanox
    skip
    zn = AlgoliaFeed::Zanox.new(index_name: 'testing', debug:0, tmpdir: '/tmp')
    zn.algolia.connect('testing')
    e = nil
    begin
      zn.process_xml("#{Rails.root}/test/data/broken_zanox.xml")
    rescue => e
    end
    assert(e != nil)
  end

  def test_zanox_conforama
    zn = AlgoliaFeed::Zanox.new(index_name: 'testing', debug:0, tmpdir: '/tmp')
    zn.algolia.connect('testing')
    zn.process_xml("#{Rails.root}/test/data/zanox_conforama.xml")
    sleep 1
    hits = zn.algolia.index.search('')['hits']
    assert_equal(1, hits.size)
    item = hits.first
    assert('Conforama', item['merchant_name'])
    assert_equal(0, item['_tags'].grep(/\Aean:/).size)
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
    assert_equal("http://pdt.tradedoubler.com/click?a(2299963)p(77225)prod(1526414519)ttid(5)url(http%3A%2F%2Feulerian.monshowroom.com%2Fdynclick%2Fmonshowroom-fr%2F%3Fetf-name%3DFlux-tradedoubler_nouveautes%26etf-prdref%3D150708%26eparam%3D%5BTD_AFFILIATE_ID%5D%26eurl%3Dhttp%253A%252F%252Fwww.monshowroom.com%252Ffr%252Fzoom%252Fun-jour-mon-prince%252Fpochette-irisee-mini-pompon%252F150708%253Futm_source%253Dtradedoubler%2526utm_medium%253Daffiliation%2526utm_term%253D%257BKEYWORD%257D)", td.url_monetizer.get('http://www.monshowroom.com/fr/zoom/un-jour-mon-prince/pochette-irisee-mini-pompon/150708'))
  end


  def test_webgains
    wg = AlgoliaFeed::Webgains.new(index_name: 'testing', debug:0, tmpdir: '/tmp')
    wg.algolia.connect('testing')
    wg.process_xml("#{Rails.root}/test/data/webgains.xml")
    sleep 1
    hits = wg.algolia.index.search('')['hits']
    assert_equal(1, hits.size)
    item = hits.first
    assert_equal('eden-deco.fr', item['merchant_name'])
    assert_equal('http://www.eden-deco.fr/bougie-spirale-ivoire-24cm-cerabella-1001.html?referer=webgains', item['product_url'])
    assert(item['_tags'].include?('category:Bougies et Bougeoires'))
    assert(item['_tags'].include?('category:Bougies Festives'))
  end

end
