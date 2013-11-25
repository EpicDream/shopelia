# -*- encoding : utf-8 -*-

require 'rubygems'
require 'algoliasearch'

module AlgoliaFeed

# TODO: Admin page

  class AlgoliaFeed

    attr_accessor :index_name, :prod_index_name, :index, :debug, :batch_size

    def self.make_production(params={})
      self.new(params).make_production
    end

    def initialize(params={})
      self.batch_size      = params[:batch_size]      || 1000
      self.index_name      = params[:index_name]      || 'products-feed-fr-new'
      self.prod_index_name = params[:prod_index_name] || 'products-feed-fr'
      self.debug           = params[:debug]           || 0
    end

    def connect(index_name=nil)
      self.index = Algolia::Index.new(index_name || self.index_name)
    end

    def make_production
      Algolia.move_index(self.index_name, self.prod_index_name)
    end

    def set_index_attributes
      self.index.set_settings({"attributesToIndex" => ['name', 'brand', 'reference', 'price'], "customRanking" => ["asc(rank)"]})
    end

    def send_batch(records)
      return unless records.size > 0
      self.index.add_objects(records)
    end

  end
end

require_relative 'filer'
require_relative 'xml_parser'
require_relative 'tagger'
require_relative 'price_minister'
require_relative 'tradedoubler'
require_relative 'zanox'
require_relative 'amazon'
require_relative 'webgains'
require_relative 'publicidees'

