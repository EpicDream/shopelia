# -*- encoding : utf-8 -*-
require 'test_helper'

class Scrapers::ReverseDirectoryTest < ActiveSupport::TestCase
  require "#{Rails.root}/lib/scrapers/reverse_directory"

  test "it should scrape 118000 directory" do
    VCR.use_cassette('scrapers/reverse_directory') do  
      scraper = Scrapers::ReverseDirectory::Scraper118100.new
      scraper.lookup "0959497434"
      result = scraper.result

      assert_equal "Eric", result[:first_name]
      assert_equal "Larchevêque", result[:last_name]
      assert_equal "14 boulevard du chateau", result[:address1]
      assert_equal "92200", result[:zip]
      assert_equal "Neuilly-sur-seine", result[:city]
    end
  end
  
  test "it should lookup phone number" do
    VCR.use_cassette('scrapers/reverse_directory') do  
      result = Scrapers::ReverseDirectory.lookup "0959497434"
      assert_equal 5, result.size
    do
  end

end
