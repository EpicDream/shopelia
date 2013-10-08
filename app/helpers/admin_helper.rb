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

  def order_state_to_html state
    klass = case state
    when "pending_agent" then "label-important"
    when "failed" then "label-warning"
    when "completed" then "label-success"
    when "querying" then "label-info"
    end
    "<span class='label #{klass}'>#{state.camelize}</span>"
  end
  
  def event_action_to_html action
    case action
    when Event::VIEW then "<span class='label label-warning'>view</span>"
    when Event::CLICK then "<span class='label label-success'>click</span>"
    when Event::REQUEST then "<span class='label'>request</span>"
    end
  end

  def viking_failure_tags product
    split_versions = product.product_versions.where(available:[nil,true]).count > 1 
    result = ""
    product.product_versions.where(available:[nil,true]).each do |v|
      tmp = ""
      tmp += '<span class="label">Price</span> ' if v.price.nil?
      tmp += '<span class="label">Shipping price</span> ' if v.price_shipping.nil?
      tmp += '<span class="label">Name</span> ' if v.name.nil?
      tmp += '<span class="label">Image url</span> ' if v.image_url.nil?
      tmp += '<span class="label">Shipping info</span> ' if v.shipping_info.nil?
      tmp += '<span class="label">Description</span> ' if v.description.nil?
      tmp += '<span class="label">Availability</span> ' if v.available.nil?
      result += split_versions ? tmp.length > 0 ? "{#{v.id}} [ #{tmp} ] " : "" : tmp
    end
    result.blank? ? "Empty data" : result
  end

  def number_to_knob n
    if n.to_i == 100
      100
    else
      sprintf("%.2f", n)
    end
  end 

  def conversion_rate target, total
    p = target.to_f * 100 / (total == 0 ? 1 : total)
    sprintf("%.2f", p) + "%"
  end

  def semaphore success
    image_tag(
      case success
      when nil then "empty.png"
      when true then "admin/green_light.png"
      when false then "admin/red_light.png"
      end)      
  end

end
