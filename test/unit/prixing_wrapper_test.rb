# -*- encoding : utf-8 -*-
require 'test_helper'

class PrixingWrapperTest < ActiveSupport::TestCase
 
  setup do
    prixing_result = Prixing::Product.get("9782749910116")
    @result = PrixingWrapper.convert(prixing_result)
  end

  test "it should set name" do
    assert_match /Métronome/, @result[:name]
  end

  test "it should set image url" do
    assert_equal "http://www.prixing.fr/images/product_images/b6a/b6aacf56d04df065e64aa3f6c4eb2faf.jpg", @result[:image_url]
  end

  test "it should set prices" do
    assert_equal ["http://www.amazon.fr/Métronome-Lhistoire-France-rythme-parisien/dp/2749910110?SubscriptionId=AKIAJMEFP2BFMHZ6VEUA&tag=prixing-web-21&linkCode=xm2&camp=2025&creative=165953&creativeASIN=2749910110", "http://ad.zanox.com/ppc/?19054231C2048768278&ULP=%5B%5Blivre.fnac.com/a2607831/Lorant-Deutsch-Metronome%5D%5D#fnac.com"].to_set, @result[:urls].to_set
  end
end
