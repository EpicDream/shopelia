class Admin::ThemesPreviewsController < Admin::AdminController
  
  def show
    @themes = Theme.pre_published_or_published.order('position asc')
  end
end