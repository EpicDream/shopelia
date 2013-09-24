class Shopelia.Models.Product extends Backbone.RelationalModel
  name: "product"

  setQuantity: (data) ->
    console.log("Quantity " + data)
    @set("quantity", data)

  setProduct: (data) ->
    console.log("setData")
    console.log(data)
    @set({
      available: data.versions.length > 0,
      merchant_name: data.merchant.name,
      merchant_logo: data.merchant.logo,
      allow_quantities: data.merchant.allow_quantities,
      quantity: 1,
      ready: data.ready,
      options_completed: data.options_completed,
      versions: data.versions
    })
    if @get('available')
      if @get('version_index') > 0
        @setVersionByIndex(@get('version_index'))
      else
        @setVersionByIndex(0)

  setVersionByIndex: (index) ->
    if index == -1
      @set({
        version_index: null,
        option1_md5: null,
        option2_md5: null,
        option3_md5: null,
        option4_md5: null,
        product_version_id: null,
        expected_price_strikeout: null,
        expected_price_shipping: null,
        expected_price_product: null,
        expected_cashfront_value: null,
        shipping_info: null,
        availability_info: null,
        name: null,
        image_url: null,
        description: null
      })        
    else
      versions = @get('versions')
      @set({
        version_index: index,
        option1_md5: versions[index].option1_md5,
        option2_md5: versions[index].option2_md5,
        option3_md5: versions[index].option3_md5,
        option4_md5: versions[index].option4_md5,
        product_version_id: versions[index].id,
        expected_price_strikeout: versions[index].price_strikeout,
        expected_price_shipping: versions[index].price_shipping,
        expected_price_product: versions[index].price,
        expected_cashfront_value: 0,
        shipping_info: versions[index].shipping_info,
        availability_info: versions[index].availability_info,
        name: versions[index].name,
        image_url: versions[index].image_url,
        description: versions[index].description
      })    
      if versions[index].cashfront_value > 0
        @set({
          expected_price_strikeout: versions[index].price
          expected_cashfront_value: versions[index].cashfront_value
        })
      r = @get('shipping_info') 
      if @get('availability_info') && @get('availability_info') != r
        r += "<br><small>" + @get('availability_info') + "</small>"
      @set({shipping_info_full: r})

  setVersion: (key, value) ->
    if key == "option1"
      option1_md5 = value
    else
      option1_md5 = @get('option1_md5')
    if key == "option2"
      option2_md5 = value
    else
      option2_md5 = @get('option2_md5')
    if key == "option3"
      option3_md5 = value
    else
      option3_md5 = @get('option3_md5')
    if key == "option4"
      option4_md5 = value
    else
      option4_md5 = @get('option4_md5')

    index = -1
    versions = @get('versions')
    if key == "option1"
      for i in [0..versions.length - 1] by 1
        if versions[i].option1_md5 == option1_md5 && versions[i].option2_md5 == option2_md5 && versions[i].option3_md5 == option3_md5 && versions[i].option4_md5 == option4_md5
          index = i
      if index == -1
        for i in [0..versions.length - 1] by 1
          if versions[i].option1_md5 == option1_md5 && versions[i].option2_md5 == option2_md5 && versions[i].option3_md5 == option3_md5
            index = i
      if index == -1
        for i in [0..versions.length - 1] by 1
          if versions[i].option1_md5 == option1_md5 && versions[i].option2_md5 == option2_md5
            index = i
      if index == -1
        for i in [0..versions.length - 1] by 1
          if versions[i].option1_md5 == option1_md5
            index = i
    if key == "option2"
      for i in [0..versions.length - 1] by 1
        if versions[i].option1_md5 == option1_md5 && versions[i].option2_md5 == option2_md5 && versions[i].option3_md5 == option3_md5 && versions[i].option4_md5 == option4_md5
          index = i
      if index == -1
        for i in [0..versions.length - 1] by 1
          if versions[i].option1_md5 == option1_md5 && versions[i].option2_md5 == option2_md5 && versions[i].option3_md5 == option3_md5
            index = i
      if index == -1
        for i in [0..versions.length - 1] by 1
          if versions[i].option1_md5 == option1_md5 && versions[i].option2_md5 == option2_md5
            index = i
      if index == -1
        for i in [0..versions.length - 1] by 1
          if versions[i].option2_md5 == option2_md5
            index = i
    if key == "option3"
      for i in [0..versions.length - 1] by 1
        if versions[i].option1_md5 == option1_md5 && versions[i].option2_md5 == option2_md5 && versions[i].option3_md5 == option3_md5 && versions[i].option4_md5 == option4_md5
          index = i
      if index == -1
        for i in [0..versions.length - 1] by 1
          if versions[i].option1_md5 == option1_md5 && versions[i].option2_md5 == option2_md5 && versions[i].option3_md5 == option3_md5
            index = i
      if index == -1
        for i in [0..versions.length - 1] by 1
          if versions[i].option1_md5 == option1_md5 && versions[i].option3_md5 == option3_md5
            index = i
      if index == -1
        for i in [0..versions.length - 1] by 1
          if versions[i].option3_md5 == option3_md5
            index = i
    if key == "option4"
      for i in [0..versions.length - 1] by 1
        if versions[i].option1_md5 == option1_md5 && versions[i].option2_md5 == option2_md5 && versions[i].option3_md5 == option3_md5 && versions[i].option4_md5 == option4_md5
          index = i
      if index == -1
        for i in [0..versions.length - 1] by 1
          if versions[i].option1_md5 == option1_md5 && versions[i].option2_md5 == option2_md5 && versions[i].option4_md5 == option4_md5
            index = i
      if index == -1
        for i in [0..versions.length - 1] by 1
          if versions[i].option1_md5 == option1_md5 && versions[i].option4_md5 == option4_md5
            index = i
      if index == -1
        for i in [0..versions.length - 1] by 1
          if versions[i].option4_md5 == option4_md5
            index = i

    @setVersionByIndex(index)

  getExpectedTotalPrice: ->
    @get('expected_price_product') * @get('quantity') + @get('expected_price_shipping')
