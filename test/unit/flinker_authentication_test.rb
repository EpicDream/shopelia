require 'test_helper'

class FlinkerAuthenticationTest < ActiveSupport::TestCase

  setup do
    @flinker_authentication = flinker_authentications(:amine)
  end

  test "it should fetch data from provider" do
    skip
    data = FlinkerAuthentication.fetch_data(@flinker_authentication.provider,@flinker_authentication.token)
    assert_equal data[:email], "bellakra@eleves.enpc.fr"
    assert_equal data[:uid], "693006605"
    assert_equal data[:username], "amine.bellakrid"
  end

  test "it should raise error if token is invalid" do
    data = FlinkerAuthentication.fetch_data(@flinker_authentication.provider,"jfjfj")
    assert_equal data[:status], 401
  end
end