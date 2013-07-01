# -*- encoding : utf-8 -*-
module ApplicationHelper

  def javascript(*files)
    content_for(:head) { javascript_include_tag(*files) }
  end

end
