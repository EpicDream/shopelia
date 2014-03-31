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
  
  def actual_countries_for_select opts={}
    countries = Country.in_use.map{|c| [c.name, c.id]}
    countries.insert(0, ["Tous les pays", nil]) if opts[:include_all_option]
    countries
  end
  
  def themes_for_select opts={}
    [[opts[:default], nil]] + Theme.all.map { |theme| [theme.title_for_display, theme.id] }
  end
  
  def fonts_for_select
    ['HelveticaNeue-Bold','HelveticaNeue-BoldItalic', 'HelveticaNeue-Medium', 'HelveticaNeue-MediumItalic', 
      'HelveticaNeue', 'HelveticaNeue-Italic', 'HelveticaNeue-Light', 'HelveticaNeue-LightItalic', 
      'HelveticaNeue-Thin', 'HelveticaNeue-ThinItalic']
  end
  
  def fonts_sizes_for_select
    (10..30).step(2).to_a
  end
  
  def country_flag_image iso
    image_tag "flags/#{iso.downcase}.png" if iso
  end
end
