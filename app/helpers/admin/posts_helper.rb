module Admin::PostsHelper
  
  def look_preview_header post
    content_tag(:span, post.look.flinker.username, class:'look-username') +
    content_tag(:span, I18n.l(post.published_at), class:'look-published-at') +
    check_box_tag("reject-look-#{post.id}", '1', false, class:'look-reject-checkbox', 'data-look-id' => post.look.id) +
    button_tag(class:'btn btn-danger look-direct-reject', 'data-look-id' => post.look.id) {
      content_tag(:i, '', class:'icon-trash icon-white')
    }
  end
  
  def look_preview post
    link_to content_tag(:div) { 
      url = post.look.look_images.first.picture(:large) if post.look.look_images.first
      url ||= post.images.first
      image_tag(url) + 
      content_tag(:p, post.title, class:"post-title")
    }, admin_post_path(post)
  end
end
