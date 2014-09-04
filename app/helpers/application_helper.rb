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
  
  def actual_countries_for_select
    Country.in_use.map{|c| [c.name, c.id]}
  end
  
  def themes_for_select opts={}
    [[opts[:default], nil]] + 
    Theme.where('series >= ?', Theme.last_series - 1).order(:created_at).map { |theme| 
      ["#{theme.title_for_display} - #{l(theme.created_at, format: '%d-%m-%Y')}", theme.id] 
    }
  end
  
  def grouped_themes_for_select look
    themes = Theme.where('series >= ?', Theme.last_series - 1).order(:created_at)
    content_tag(:select, id:"assign-to-theme", "data-look-id" => look.id, class:"theme-select") do
      content_tag(:option, "Ajouter à une collection") +
      themes.group_by {|theme| theme.series }.map do |series, themes|
        content_tag(:optgroup, label:"Série #{series}") do
          options_for_select(themes.map{|t| ["#{t.title_for_display}", t.id] })
        end
      end.join.html_safe
    end
  end
  
  def fonts_for_select
    Theme::FONTS
  end
  
  def fonts_sizes_for_select
    Theme::SIZES
  end
  
  def country_flag_image iso
    image_tag "flags/#{iso.downcase}.png" if iso
  end
  
  def autocomplete_publishers_usernames
    Flinker.publishers.select([:id, :username]).map{ |f| { id:f.id, label:f.username } }.to_json
  end
  
  def flinkwebsite_common_keywords
    ["fashion", "mode", "flink", "looks", "trendy", "paris", "look à la mode", "trendy looks", "fashion looks"] + 
    ["comment m'habiller", "what to wear today"]
  end
  
  def device_suffix
    return '.mobile' if in_mobile_view?
    return '.tablet' if in_tablet_view?
    nil
  end
end
