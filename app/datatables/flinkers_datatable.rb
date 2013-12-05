class FlinkersDatatable
  delegate :params, :h, :link_to, :image_tag, :number_with_delimiter, :raw, :admin_flinker_path, to: :@view

  def initialize(view, filters={})
    @view = view
    @filters = filters
  end

  def as_json(options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: flinkers.count,
      iTotalDisplayRecords: flinkers.total_entries,
      aaData: data
    }
  end

  private

  def data
    flinkers.map do |flinker|
      blog = Blog.find_by_flinker_id(flinker.id)
      [
        flinker.id,
        link_to(flinker.name || flinker.url, admin_flinker_path(flinker)),
        image_tag(flinker.avatar.blank? ? "empty.png" : flinker.avatar.url, class:"avatar"),
        number_with_delimiter(flinker.looks.where(is_published:true).count),
        number_with_delimiter(blog ? blog.posts.count : 0),
        flinker.url,
        flinker.is_publisher? ? "Yes" : "No"
      ]
    end
  end

  def flinkers
    @flinkers ||= fetch_flinkers
  end

  def fetch_flinkers
    flinkers = Flinker.order(:id)
    flinkers = flinkers.where("is_publisher=?", @filters[:publisher] == 'Yes' ? "t" : "f") if @filters[:publisher].present?
    flinkers = flinkers.where("name like :search or url like :search", search: "%#{params[:sSearch]}%") if params[:sSearch].present?
    flinkers.page(page).per_page(per_page)
  end

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
  end
end