# -*- encoding : utf-8 -*-
module ApplicationHelper

  def javascript(*files)
    content_for(:head) { javascript_include_tag(*files) }
  end

  def bootstrap_class_for flash_type
    case flash_type
      when :success
        "alert-success"
      when :error
        "alert-error"
      when :alert
        "alert-block"
      when :notice
        "alert-info"
      else
        flash_type.to_s
    end
  end
  
  def countries_for_select
    [['Tous les pays', ''], ['France', 'FR'], ['Allemagne', 'DE'], ['Grande Bretagne', 'GB'],
     ['Italie', 'IT'], ['Etats Unis', 'US']]
  end
  
end
