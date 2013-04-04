module Vulcain

  require 'json'
  require 'base64'
  require 'openssl'
  require 'net/http'

  class Configuration
    attr_accessor :base_url, :api_key, :preproduction

    def preproduction
      @preproduction || false
    end

    def base_url
      @base_url || (@preproduction == true  ? "http://vulcain-staging.shopelia.fr" : "http://vulcain.shopelia.fr")
    end
    
  end

  class << self
    attr_accessor :configuration
  end

  def self.configure
    self.configuration ||= Configuration.new
    yield configuration
  end

  class Ressource

  protected

    def self.post_request(route, data)
      request('POST', route, data)
    end

    def self.get_request(route, options=nil)
      request('GET', route, nil, options)
    end

    def self.put_request(route, data)
      request('PUT', route, data)
    end

    def self.delete_request(route)
      request('DELETE', route)
    end

  private

    def self.request(method, route, data=nil, options=nil)
      path = path_for(route, options)
      uri = uri_for(path)
      method = method.upcase
      data = data.to_json unless data.nil?
      headers = prepare_headers
      res = Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
        case method
        when 'POST'   then request = Net::HTTP::Post.new(uri.request_uri, headers)
        when 'GET'    then request = Net::HTTP::Get.new(uri.request_uri, headers)
        when 'PUT'    then request = Net::HTTP::Put.new(uri.request_uri, headers)
        when 'DELETE' then request = Net::HTTP::Delete.new(uri.request_uri, headers)
        else
          return {}
        end
        request.body = data unless data.nil?
        http.request request
      end
      begin
        JSON.parse(res.body)
      rescue JSON::ParserError => e
        res.body.is_a?(String) ? res.body : {'Error' => 'invalid json response' }
      end
    end

    def self.path_for(route, options)
      File.join('', route.to_s) + (options.nil? ? '' : ('?' + options))
    end

    def self.uri_for(path)
      URI(File.join(Vulcain.configuration.base_url, path))
    end
    
    def self.prepare_headers
      { 'X-Vulcain-Api-Key' => Vulcain.confirugration.api_key, 'Content-Type' => 'application/json' }
    end

  end
end

