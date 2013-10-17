module DevelopersHelper

  def product_availability product
    image_tag(
      case product.ready?
      when false then "admin/gray_light.png"
      when true then
        case product.available?
        when nil then "empty.png"
        when true then "admin/green_light.png"
        when false then "admin/red_light.png"
        end
      end)      
  end

  def product_viking_status product
    image_tag(
      case product.viking_failure?
      when nil then "empty.png"
      when true then "admin/red_light.png"
      when false then 
        case product.ready?
        when true then "admin/green_light.png"
        when false then "admin/orange_light.png"
        end
      end)      
  end  
end