# -*- encoding : utf-8 -*-
require 'test_helper'

class Google::PlacesApiTest < ActiveSupport::TestCase
  require "#{Rails.root}/lib/google/places_api"

  test "it should autocomplete address" do
    VCR.use_cassette('places_api') do  
      results = Google::PlacesApi.autocomplete "21 rue d'Abou", 48.84, 2.24
      assert_equal 5, results.count
      
      address = results.first
      assert address["reference"].present?
      assert_equal "21 Rue d'Aboukir, Paris, France", address["description"]
    end
  end
  
  test "it should query address details" do
    VCR.use_cassette('places_api') do  
      address = Google::PlacesApi.details "CjQjAAAAPtgCbee5jsEkoWoc6apT3qFBYmWlxcVOPrwUBoQ5Pqv8ExTxyh-M--tsL8QAT8xCEhBo2z7K3wdT4K6S7smh--ZIGhTCBtyjxjD5fBNcR15jutp7SZA2Fw"

      assert_equal "21 Rue d'Aboukir", address["address1"]
      assert_equal "75002", address["zip"]
      assert_equal "Paris", address["city"]
      assert_equal "FR", address["country"]
    end
  end

end
