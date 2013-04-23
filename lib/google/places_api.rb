module Google

  class PlacesApi

    API_KEY = "AIzaSyDy_IvoH2PkTUM3e_5FBwMjHotCkNX1fTY"
    
    AUTOCOMPLETE_URI = "https://maps.googleapis.com/maps/api/place/autocomplete/json"
    DETAILS_URI = "https://maps.googleapis.com/maps/api/place/details/json"

    def self.autocomplete query, lat, lng
      options = {
        :input => query,
        :location => "#{lat},#{lng}",
        :radius => 100,
        :sensor => true,
        :key => API_KEY
      }
      response = self.request AUTOCOMPLETE_URI, options
      (response["predictions"] || []).map do |result|
        { "description" => result["description"], "reference" => result["reference"] }
      end
    end
    
    def self.details reference
      options = {
        :reference => reference,
        :sensor => true,
        :key => API_KEY
      }
      response = self.request DETAILS_URI, options
      return [] if !response["status"].eql?("OK")
      response["result"]["address_components"].each do |part|
        @street_number = part["long_name"] if part["types"].include?("street_number")
        @route = part["long_name"] if part["types"].include?("route")
        @zip = part["long_name"] if part["types"].include?("postal_code")
        @city = part["long_name"] if part["types"].include?("locality")
        @country = part["short_name"] if part["types"].include?("country")
      end
      { "address1" => "#{@street_number} #{@route}",
        "zip" => @zip,
        "city" => @city,
        "country" => @country }
    end
    
    private

    def self.request path, options
      uri = URI(path + '?' + URI.encode_www_form(options))
      headers = prepare_headers
      res = Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
        request = Net::HTTP::Get.new(uri.request_uri, headers)
        http.request request
      end
      if res.code.to_i == 200
        begin
          JSON.parse(res.body)
        rescue JSON::ParserError => e
          res.body.is_a?(String) ? {} : {'Error' => 'invalid json response' }
        end
      else
        {'Error' => 'invalid parameters'}
      end
    end

    def self.prepare_headers
      { 'Content-Type' => 'application/json', 'Accept' => 'application/json' }
    end

  end
end

