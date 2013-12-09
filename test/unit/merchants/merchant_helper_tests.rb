# -*- encoding : utf-8 -*-

module MerchantHelperTests

  # setup do
  #   @helperClass = ??
  #   @url = "http://www.luisaviaroma.com/index.aspx?#ItemSrv.ashx|SeasonId=57I&CollectionId=07H&ItemId=12"
  #   @version = {}
  #   @helper = @helperClass.new(@url)

  #   @availability_text = [
  #     {input: "36 - Dernière paire !", out: "Dernière paire !"},
  #   ]
  #   @price_shipping_text = [
  #     {input: "Supplément de 5 €",
  #      out: @helperClass"Supplément de 5 €"}
  #   ]
  #   @shipping_info = "Délai de 5 jours"
  #   @image_url = {input: "http://images.luisaviaroma.com/Big57I/07H/012_26efd1da-d067-4a0b-a075-af1964dedbd1.JPG"
  #                 out: "http://images.luisaviaroma.com/Zoom57I/07H/012_26efd1da-d067-4a0b-a075-af1964dedbd1.JPG"}
  #   @images = {input:"http://images.luisaviaroma.com/Total57I/07H/012_fe8525c8-d6c2-49ff-9715-0bc6841a8bbe.JPG"
  #              out: "http://images.luisaviaroma.com/Zoom57I/07H/012_fe8525c8-d6c2-49ff-9715-0bc6841a8bbe.JPG"}
  #   @monetize = [
  #     {input: "http://www.amazon.fr/Port-designs-Detroit-tablettes-pouces/dp/B00BIXXTCY",
  #       out: "http://www.amazon.fr/Port-designs-Detroit-tablettes-pouces/dp/B00BIXXTCY?tag=shopelia-21"},
  #     {input: """http://www.amazon.fr/Port-designs-Detroit-tablettes-pouces/dp/B00BIXXTCY?SubscriptionId=AKIAJMEFP2BFMHZ6VEUA&linkCode=xm2&camp=2025&creative=165953&creativeASIN=B00BIXXTCY",
  #      out: "http://www.amazon.fr/Port-designs-Detroit-tablettes-pouces/dp/B00BIXXTCY?SubscriptionId=AKIAJMEFP2BFMHZ6VEUA&linkCode=xm2&camp=2025&creative=165953&creativeASIN=B00BIXXTCY&tag=shopelia-21"}
  #   ]
  #   @canonize = [
  #     {input: "http://www.amazon.fr/Port-designs-Detroit-tablettes-pouces/dp/B00BIXXTCY",
  #      out: "http://www.amazon.fr/dp/B00BIXXTCY"},
  #     {input: "http://www.amazon.fr/gp/product/B00E7OA2EE", 
  #      out: "http://www.amazon.fr/gp/product/B00E7OA2EE/ref=s9_al_bw_g23_ir04?pf_rd_m=A1X6FK5RDHNB96&pf_rd_s=center-2&pf_rd_r=0ENBSWCDW130V5QJKZEV&pf_rd_t=101&pf_rd_p=431613487&pf_rd_i=13910691"
  #   ]
  #   @availabilities = {
  #     "TVA incluse le cas échéant" => false,
  #   }

  # end

  def test_it_should_find_class_from_url
    assert MerchantHelper.send(:from_url, @url).kind_of?(@helperClass)
  end

  def test_it_should_canonize
    toArray(@canonize).each do |url|
      assert_equal url[:out], @helperClass.new(url[:input]).canonize, "with #{url[:input]}"
    end
  end

  def test_it_should_parse_specific_availability
    return unless @helper.availabilities.size > 0
    assert_not_nil @availabilities, "There are availabilities. You must define tests !"
    assert_operator @helper.availabilities.size, :>=, @availabilities.size, "Missing tests !"

    @availabilities.each do |txt, result|
      assert_equal result, @helper.parse_availability(txt)[:avail], "with #{txt}"
    end
  end

  def test_it_should_process_availability
    if @helperClass.public_instance_methods(false).include?(:process_availability)
      assert_not_nil @availability_text, "You have redefined process_availability. You must define tests !"
    end

    toArray(@availability_text).each do |avail|
      @version[:availability_text] = avail[:input]
      @version = @helper.process_availability(@version)
      assert_equal avail[:out], @version[:availability_text], "with #{avail[:input]}"
    end
  end

  def test_it_should_process_availability_when_setAvailableIfEmpty_is_true
    return unless @helper.config[:setAvailableIfEmpty]
    @version[:availability_text] = ""
    @version = @helper.process_availability(@version)
    assert_equal MerchantHelper::AVAILABLE, @version[:availability_text], "setAvailableIfEmpty is true"
  end

  def test_it_should_process_availability_when_setUnavailableIfEmpty_is_true
    return unless @helper.config[:setUnavailableIfEmpty]
    @version[:availability_text] = ""
    @version = @helper.process_availability(@version)
    assert_equal MerchantHelper::UNAVAILABLE, @version[:availability_text], "setUnavailableIfEmpty is true"
  end

  def test_it_should_process_price
    if @helperClass.public_instance_methods(false).include?(:process_price)
      assert_not_nil @price_text, "You have redefined process_price. You must define tests !"
    end

    toArray(@price_text).each do |price|
      @version[:price_text] = price[:input]
      @version = @helper.process_price(@version)
      assert_equal price[:out], @version[:price_text], "with #{price[:input]}"
    end
  end

  def test_it_should_process_price_shipping
    if @helperClass.public_instance_methods(false).include?(:process_price_shipping)
      assert_not_nil @price_shipping_text, "You have redefined process_price_shipping. You must define tests !"
    elsif @helper.free_shipping_limit
      assert_not_nil @price_shipping_text, "You have defined free_shipping_limit. You must define tests !"
    end

    assert_not_nil @helper.default_price_shipping if @helper.config[:setDefaultPriceShippingAlways] || @helper.config[:setDefaultPriceShippingIfEmpty]

    toArray(@price_shipping_text).each do |price|
      @version[:price_text] = price[:price_text] if price[:price_text]
      @version[:price_shipping_text] = price[:input]
      @version = @helper.process_price_shipping(@version)
      assert_equal price[:out], @version[:price_shipping_text], "with #{price[:input]}"
    end
  end

  def test_it_should_process_price_shipping_with_free_limit
    return unless @helper.free_shipping_limit
    @version[:price_text] = "%.2f €" % (@helper.free_shipping_limit-1)
    @version[:price_shipping_text] = @helper.default_price_shipping || "3 € 50"
    @version = @helper.process_price_shipping(@version)
    assert_equal @helper.default_price_shipping || "3 € 50", @version[:price_shipping_text]

    @version[:price_text] = "%.2f €" % (@helper.free_shipping_limit+1)
    @version[:price_shipping_text] = @helper.default_price_shipping || "3 € 50"
    @version = @helper.process_price_shipping(@version)
    assert_equal MerchantHelper::FREE_PRICE, @version[:price_shipping_text]
  end

  def test_it_should_process_price_shipping_when_setDefaultPriceShippingIfEmpty_is_true
    return unless @helper.config[:setDefaultPriceShippingIfEmpty]

    @version[:price_shipping_text] = ""
    @version = @helper.process_price_shipping(@version)
    assert_equal @helper.default_price_shipping, @version[:price_shipping_text], "setDefaultPriceShippingIfEmpty is true"

    @version[:price_shipping_text] = "84 € 51"
    @version = @helper.process_price_shipping(@version)
    assert_equal "84 € 51", @version[:price_shipping_text], "setDefaultPriceShippingAlways is true"
  end

  def test_it_should_process_price_shipping_when_setDefaultPriceShippingAlways_is_true
    return unless @helper.config[:setDefaultPriceShippingAlways]

    @version[:price_shipping_text] = ""
    @version = @helper.process_price_shipping(@version)
    assert_equal @helper.default_price_shipping, @version[:price_shipping_text], "setDefaultPriceShippingAlways is true"

    @version[:price_shipping_text] = "84 € 51"
    @version = @helper.process_price_shipping(@version)
    assert_equal @helper.default_price_shipping, @version[:price_shipping_text], "setDefaultPriceShippingAlways is true"
  end

  def test_it_should_process_shipping_info
    if @helperClass.public_instance_methods(false).include?(:process_shipping_info)
      assert_not_nil @shipping_info, "You have redefined process_shipping_info. You must define tests !"
    end

    assert_not_nil @helper.default_shipping_info if @helper.config[:setDefaultShippingInfoAlways] || @helper.config[:setDefaultShippingInfoIfEmpty]

    toArray(@shipping_info).each do |info|
      @version[:shipping_info] = info[:input]
      @version = @helper.process_shipping_info(@version)
      assert_equal info[:out], @version[:shipping_info], "with #{info[:input]}"
    end
  end

  def test_it_should_process_shipping_info_when_setDefaultShippingInfoIfEmpty_is_true
    return unless @helper.config[:setDefaultShippingInfoIfEmpty]

    @version[:shipping_info] = ""
    @version = @helper.process_shipping_info(@version)
    assert_equal @helper.default_shipping_info, @version[:shipping_info], "setDefaultShippingInfoIfEmpty is true"

    text = "Dans quelque jours ça va arriver !"
    @version[:shipping_info] = text
    @version = @helper.process_shipping_info(@version)
    assert_match text, @version[:shipping_info], "setDefaultShippingInfoIfEmpty is true"
  end

  def test_it_should_process_shipping_info_when_setDefaultShippingInfoAlways_is_true
    return unless @helper.config[:setDefaultShippingInfoAlways]

    @version[:shipping_info] = ""
    @version = @helper.process_shipping_info(@version)
    assert_equal @helper.default_shipping_info, @version[:shipping_info], "setDefaultShippingInfoAlways is true"

    @version[:shipping_info] = "Dans quelque jours ça va arriver !"
    @version = @helper.process_shipping_info(@version)
    assert_match @helper.default_shipping_info, @version[:shipping_info], "setDefaultShippingInfoAlways is true"
  end

  def test_it_should_process_shipping_info_when_addDefaultShippingInfoBefore_is_true
    return unless @helper.config[:addDefaultShippingInfoBefore]

    @version[:shipping_info] = ""
    @version = @helper.process_shipping_info(@version)
    assert_equal @helper.default_shipping_info, @version[:shipping_info], "addDefaultShippingInfoBefore is true"

    text = "Dans quelque jours ça va arriver !"
    @version[:shipping_info] = text
    @version = @helper.process_shipping_info(@version)
    assert_equal @helper.default_shipping_info + text, @version[:shipping_info], "addDefaultShippingInfoBefore is true"
  end

  def test_it_should_process_shipping_info_when_addDefaultShippingInfoAfter_is_true
    return unless @helper.config[:addDefaultShippingInfoAfter]

    @version[:shipping_info] = ""
    @version = @helper.process_shipping_info(@version)
    assert_equal @helper.default_shipping_info, @version[:shipping_info], "addDefaultShippingInfoAfter is true"

    text = "Dans quelque jours ça va arriver !"
    @version[:shipping_info] = text
    @version = @helper.process_shipping_info(@version)
    assert_equal text + @helper.default_shipping_info, @version[:shipping_info], "addDefaultShippingInfoAfter is true"
  end

  def test_it_should_process_image_url
    if @helperClass.public_instance_methods(false).include?(:process_image_url)
      assert_not_nil @image_url, "You have redefined process_image_url. You must define tests !"
    elsif @helper.image_sub && ! @helper.config[:subImagesOnly]
      assert_not_nil @image_url, "You have defined image_sub. You must define tests !"
    end

    toArray(@image_url).each do |url|
      @version[:image_url] = url[:input]
      @version = @helper.process_image_url(@version)
      assert_equal url[:out], @version[:image_url], "with #{url[:input]}"
    end
  end

  def test_it_should_process_images
    if @helperClass.public_instance_methods(false).include?(:process_images)
      assert_not_nil @images, "You have redefined process_images. You must define tests !"
    elsif @helper.image_sub && ! @helper.config[:subImageUrlOnly]
      assert_not_nil @images, "You have defined image_sub. You must define tests !"
    end

    return unless @images
    @version[:images] = @images[:input]
      @version = @helper.process_images(@version)
    assert_equal @images[:out], @version[:images], "with #{@images[:input]}"
  end


  def test_it_should_process_options
    if @helperClass.public_instance_methods(false).include?(:process_options)
      assert_not_nil @options, "You have redefined process_option. You must define tests !"
    elsif @helper.config[:searchBackgroundImageOrColorForOptions]
      assert_not_nil @options, "You have defined config[:searchBackgroundImageOrColorForOptions]. You must define tests !"
    end

    toArray(@options).each do |opt|
      option = "option#{opt[:level]}"
      @version[option] = opt[:input]
      @version = @helper.process_options(@version)
      assert_equal opt[:out], @version[option], "with #{opt[:input]} for level ##{opt[:level]}"
    end

    toArray(@helper.config[:searchBackgroundImageOrColorForOptions]).each do |option|
      option = "option#{option}"
      @version[:option1] = {"style" => "background: FFFFFF;", "text" => "Blanc", "src" => ""}
      @version = @helper.process_options(@version)
      assert_equal "Blanc", @version[:option1]["text"]

      @version[:option1] = {"style" => "background: FFFFFF;", "text" => "", "src" => @url}
      @version = @helper.process_options(@version)
      assert_equal "", @version[:option1]["text"]

      @version[:option1] = {"style" => "background: FFFFFF;", "text" => "", "src" => ""}
      @version = @helper.process_options(@version)
      assert_equal "FFFFFF", @version[:option1]["text"]

      @version[:option1] = {"style" => "background: #F60409;", "text" => "", "src" => ""}
      @version = @helper.process_options(@version)
      assert_equal "#F60409", @version[:option1]["text"]
      @version[:option1] = {"style" => "background-color:#c6865a;", "text" => "", "src" => ""}
      @version = @helper.process_options(@version)
      assert_equal "#c6865a", @version[:option1]["text"]
    end
  end

  private
    # like Array(obj)
    # but Array({key: value}) => [[key, value]]
    # and toArray({key: value}) => [{key: value}]
    def toArray obj
      return [obj] if obj.kind_of?(Hash)
      Array(obj)
    end
end
