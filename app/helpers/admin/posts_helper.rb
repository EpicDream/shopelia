module Admin::PostsHelper
  
  def countries_for_select
    [['Tous les pays', ''], ['France', 'FR'], ['Allemagne', 'DE'], ['Grande Bretagne', 'GB'],
     ['Italie', 'IT'], ['Etats Unis', 'US']]
  end
  
  def look_preview_header post
    content_tag(:span, I18n.l(post.published_at), class:'look-published-at') +
    button_tag(class:'btn btn-danger look-direct-reject', 'data-look-id' => post.look.id) {
      content_tag(:i, '', class:'icon-trash icon-white')
    }
  end
  
  def look_preview post
    link_to content_tag(:div) { 
      image_tag(post.images.first) + 
      content_tag(:p, post.title, class:"post-title")
    }, admin_post_path(post)
  end
end