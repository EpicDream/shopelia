require 'httpclient'
require 'erb'
require 'securerandom'
require 'active_support/core_ext/hash/conversions'
require 'active_support/inflector'

module Virtualis

  class Configuration
    attr_accessor :endpoint_url, :messages_path, :efs, :identifiant, :contrat, :certificate, :key, :logger
  end

  class << self
    attr_accessor :configuration
  end

  def self.configure
    self.configuration ||= Configuration.new
    yield configuration
  end

end

require_relative "vsigner"
require_relative 'message'
require_relative 'request'
require_relative 'bean'
require_relative 'card'
require_relative 'report'

