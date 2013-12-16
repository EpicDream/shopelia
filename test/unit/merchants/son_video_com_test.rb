# -*- encoding : utf-8 -*-
require 'test_helper'
require_relative './merchant_helper_tests'

class SonVideoComTest < ActiveSupport::TestCase

  setup do
    @helperClass = SonVideoCom
    @version = {}
    @url = "http://www.son-video.com/Rayons/Enceinte-sans-fil/Awox-StriimLight-Mini.html"
    @helper = SonVideoCom.new(@url)

    @availabilities = {
      "Délai : nous contacter" => false,
    }
    @images = {
      input: ["http://www.son-video.com/images/dynamic/Enceintes/articles/Awox/AWOXSTRLIGHTMINI/Awox-StriimLight-Mini_P_260.jpg"],
      out: ["http://www.son-video.com/images/dynamic/Enceintes/articles/Awox/AWOXSTRLIGHTMINI/Awox-StriimLight-Mini_P_500.jpg"]
    }
  end

  include MerchantHelperTests
end
