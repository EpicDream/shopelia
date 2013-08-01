module AdminHelper

  def incidents_count
    count = Incident.where(processed:false).count
    count > 0 ? " <strong>(#{count})</strong>" : ""
  end
  
  def incident_severity_to_html s
    if s == Incident::INFORMATIVE 
      '<span class="label label-info">Info</span>'
    elsif s == Incident::IMPORTANT 
      '<span class="label label-warning">Important</span>'
    elsif s == Incident::CRITICAL 
      '<span class="label label-important">Critical</span>'
    end
  end
  
  def viking_failure_tags product
    split_versions = product.product_versions > 0
    result = ""
    product.product_versions.each do |v|
      tmp = ""
      tmp += '<span class="label">Price</span> ' if v.price.nil?
      tmp += '<span class="label">Shipping price</span> ' if v.price_shipping.nil?
      tmp += '<span class="label">Name</span> ' if v.name.nil?
      tmp += '<span class="label">Image url</span> ' if v.image_url.nil?
      tmp += '<span class="label">Shipping info</span> ' if v.shipping_info.nil?
      tmp += '<span class="label">Description</span> ' if v.description.nil?
      tmp += '<span class="label">Availability</span> ' if v.available.nil?
      result += split_versions ? "{#{v.id}} [ #{result} ] " : result
    end
    result
  end      

end
