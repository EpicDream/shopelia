require 'test_helper'

class GatewayControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  
  test "it should add event and redirect to checkout" do
  	assert_difference("EventsWorker.jobs.count", 1) do
      get :index, url:"http://www.priceminister.com/offer/buy/184578646/reflex-canon-eos-6d-24-105mm-is-usm.html", developer:developers(:prixing).api_key
      assert_redirected_to "https://www.shopelia.com/checkout?url=http%3A%2F%2Fwww.priceminister.com%2Foffer%2Fbuy%2F184578646%2Freflex-canon-eos-6d-24-105mm-is-usm.html&developer=abcde"
    end
  end

  test "it should ignore events from bot" do
    request.env['HTTP_USER_AGENT'] = "Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)"
    assert_difference("EventsWorker.jobs.count", 0) do
      get :index, url:"http://www.priceminister.com/offer/buy/184578646/reflex-canon-eos-6d-24-105mm-is-usm.html", developer:developers(:prixing).api_key
      assert_redirected_to "https://www.shopelia.com/checkout?url=http%3A%2F%2Fwww.priceminister.com%2Foffer%2Fbuy%2F184578646%2Freflex-canon-eos-6d-24-105mm-is-usm.html&developer=abcde"
    end
  end   
end