module Prixing

  require 'json'
  require 'base64'
  require 'openssl'
  require 'net/http'

  class Configuration
    attr_accessor :base_url, :device
  end

  class << self
    attr_accessor :configuration
  end

  def self.configure
    self.configuration ||= Configuration.new
    yield configuration
  end

end
