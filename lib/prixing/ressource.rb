module Prixing

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

    def self.request(method, route, data=nil, options={})
      path = path_for(route, options.merge(prepare_options))
      uri = uri_for(path)
      method = method.upcase
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
        request.body = data.to_json unless data.nil?
        http.request request
      end
      if res.code.to_i == 200
        begin
          JSON.parse(res.body)
        rescue JSON::ParserError => e
          res.body.is_a?(String) ? {} : {"Error" => "invalid json response" }
        end
      else
        {"Error" => "invalid parameters"}
      end
    rescue Exception => e
      {"Error" => e.inspect }
    end

    def self.path_for(route, options)
      File.join('', route.to_s) + (options.nil? ? '' : ('?' + options.to_query))
    end

    def self.uri_for(path)
      URI(File.join(Prixing.configuration.base_url, path))
    end
    
    def self.prepare_options
      { 'device' => Prixing.configuration.device }
    end

    def self.prepare_headers
      {}
    end

  end
end